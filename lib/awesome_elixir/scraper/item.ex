defmodule AwesomeElixir.Scraper.Item do
  @moduledoc """
  Scraping and parse data according to `AwesomeElixir.Catalog.Item` `git_source` or `url` fields value.
  """

  alias AwesomeElixir.Catalog
  alias AwesomeElixir.Scraper.{CommonHttp, GithubApi, GitlabApi, HexpmApi}
  alias HTTPoison.Response

  @doc """
    Fetch and update actual info about `AwesomeElixir.Catalog.Item`.

    * Make API-calls to `GitHub`, `GitLab` or `Hex.pm`, or just check 200/404 status codes for not API url source
    * Handle API-responses (update `AwesomeElixir.Catalog.Item`, or extract `git_source` from `Hex.pm` project metadata)
  """
  @spec update(Catalog.Item.t()) ::
          {:ok, Catalog.Item.t()}
          | {:error, Ecto.Changeset.t()}
          | {:retry, :now}
          | {:retry, DateTime.t()}

  def update(%Catalog.Item{git_source: %{github: github}, is_dead: false} = item)
      when not is_nil(github) do
    case GithubApi.get_repo(github) do
      {:ok,
       %Response{
         status_code: 200,
         body: %{pushed_at: pushed_at, watchers: stars_count, description: description}
       }} ->
        item
        |> Catalog.update_item(
          %{
            description: description,
            stars_count: stars_count,
            pushed_at: pushed_at,
            is_dead: false,
            is_scrapped: true
          }
          |> reject_blank_values()
        )

      {:ok, %Response{status_code: 404}} ->
        case Catalog.update_item(item, %{is_dead: true, is_scrapped: true}) do
          {:ok, item} -> update(item)
          error_with_changeset -> error_with_changeset
        end

      {:ok,
       %Response{
         status_code: 301,
         body: %{message: "Moved Permanently", url: "https://api.github.com" <> uri_moved_to}
       }} ->
        item
        |> handle_github_moved(uri_moved_to)

      {:ok,
       %Response{
         status_code: 403,
         body: %{message: "API rate limit exceeded for " <> _},
         headers: headers
       }} ->
        timestamp =
          headers
          |> Enum.into(%{})
          |> Map.fetch!("X-RateLimit-Reset")
          |> String.to_integer()

        {:retry, DateTime.from_unix!(timestamp + Enum.random(10..60))}

      # TODO. Handle 401 response
      _ ->
        {:retry, :now}
    end
  end

  def update(%Catalog.Item{git_source: %{github: github}, url: url, is_dead: true} = item)
      when not is_nil(github) do
    case CommonHttp.get(url) do
      {:ok, %Response{status_code: 404}} ->
        {:ok, item}

      {:ok,
       %Response{
         status_code: 301,
         headers: headers
       }} ->
        "https://github.com/" <> github =
          headers
          |> Enum.map(fn {key, value} -> {key |> String.downcase() |> String.to_atom(), value} end)
          |> Keyword.get(:location)

        item
        |> Catalog.update_item(%{
          git_source: %{github: github},
          is_dead: false,
          is_scraped: false
        })
        |> case do
          {:ok, item} -> update(item)
          error_with_changeset -> error_with_changeset
        end
    end
  end

  def update(%Catalog.Item{git_source: %{gitlab: gitlab}} = item) when not is_nil(gitlab) do
    case GitlabApi.get_project(gitlab) do
      {:ok,
       %Response{
         status_code: 200,
         body: %{star_count: stars_count, last_activity_at: pushed_at, description: description}
       }} ->
        item
        |> Catalog.update_item(
          %{
            description: description,
            stars_count: stars_count,
            pushed_at: pushed_at,
            is_dead: false,
            is_scrapped: true
          }
          |> reject_blank_values()
        )

      {:ok, %Response{status_code: 404}} ->
        item
        |> Catalog.update_item(%{is_dead: true, is_scrapped: true})

      _ ->
        {:retry, Timex.now() |> Timex.shift(seconds: Enum.random(60..120))}
    end
  end

  def update(%Catalog.Item{url: "https://hex.pm/packages/" <> hex_package} = item) do
    case extract_repo_from_hexpm(hex_package) do
      :retry ->
        {:retry, :now}

      :not_found ->
        Catalog.update_item(item, %{is_dead: true, is_scrapped: true})

      %{} = git_source when map_size(git_source) == 0 ->
        Catalog.update_item(item, %{is_dead: false, is_scrapped: true})

      %{} = git_source ->
        Catalog.update_item(item, %{git_source: git_source})
        {:retry, :now}
    end
  end

  def update(%Catalog.Item{url: url} = item) do
    case HTTPoison.get(url, [], follow_redirect: true) do
      {:ok, %Response{status_code: 200}} ->
        item
        |> Catalog.update_item(%{is_dead: false, is_scrapped: true})

      _ ->
        item
        |> Catalog.update_item(%{is_dead: true, is_scrapped: true})
    end
  end

  def update(_), do: nil

  defp handle_github_moved(item, moved_uri) do
    case GithubApi.get(moved_uri) do
      {:ok,
       %Response{
         status_code: 200,
         body: %{
           description: description,
           pushed_at: pushed_at,
           watchers: stars_count,
           html_url: "https://github.com/" <> github
         }
       }} ->
        item
        |> Catalog.update_item(
          %{
            description: description,
            stars_count: stars_count,
            pushed_at: pushed_at,
            is_dead: false,
            is_scrapped: true,
            git_source: %{github: github}
          }
          |> reject_blank_values()
        )

      _ ->
        {:retry, :now}
    end
  end

  defp extract_repo_from_hexpm(package) do
    case HexpmApi.get_package(package) do
      {:ok, %Response{status_code: 200, body: %{meta: %{links: links}}}}
      when map_size(links) > 0 ->
        Enum.reduce(Map.values(links), %{}, &extract_from_hexpm_link/2)

      {:ok, %Response{status_code: 200}} ->
        %{}

      {:ok, %Response{status_code: 404}} ->
        :not_found

      _ ->
        :retry
    end
  end

  defp extract_from_hexpm_link("https://github.com/" <> rest, repos),
    do: Map.put(repos, :github, rest)

  defp extract_from_hexpm_link("https://gitlab.com/" <> rest, repos),
    do: Map.put(repos, :gitlab, rest)

  defp extract_from_hexpm_link(_, repos), do: repos

  defp reject_blank_values(map) when is_map(map) do
    map |> Enum.reject(fn {_key, value} -> is_blank(value) end) |> Map.new()
  end

  defp is_blank(value) when (is_binary(value) and value == "") or is_nil(value), do: true
  defp is_blank(_), do: false
end
