defmodule AwesomeElixir.Scraper.Item do
  alias AwesomeElixir.Catalog
  alias AwesomeElixir.Scraper.{GithubApi, GitlabApi, HexpmApi}
  alias HTTPoison.Response

  @spec update(Catalog.Item.t()) ::
          {:ok, Catalog.Item.t()}
          | {:error, Ecto.Changeset.t()}
          | {:retry, :now}
          | {:retry, DateTime.t()}

  def update(%Catalog.Item{git_source: %{github: github}} = item) when not is_nil(github) do
    case GithubApi.get("/repos/" <> github) do
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
        item
        |> Catalog.update_item(%{is_dead: true, is_scrapped: true})

      {:ok,
       %Response{
         status_code: 301,
         body: %{message: "Moved Permanently", url: "https://api.github.com" <> moved_uri}
       }} ->
        item
        |> handle_github_moved(moved_uri)

      {:ok,
       %Response{
         status_code: 403,
         body: %{message: "API rate limit exceeded for user" <> _},
         headers: headers
       }} ->
        timestamp =
          headers
          |> Enum.into(%{})
          |> Map.fetch!("X-RateLimit-Reset")
          |> String.to_integer()

        {:retry, DateTime.from_unix!(timestamp + Enum.random(10..60))}

      _ ->
        {:retry, :now}
    end
  end

  def update(%Catalog.Item{git_source: %{gitlab: gitlab}} = item) when not is_nil(gitlab) do
    case GitlabApi.get("/projects/" <> URI.encode_www_form(gitlab)) do
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
        {:retry, :now}
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

      {:ok, %Response{status_code: 404}} ->
        item
        |> Catalog.update_item(%{is_dead: true, is_scrapped: true})

      _ ->
        {:retry, :now}
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

  defp extract_repo_from_hexpm(hex_package) do
    case HexpmApi.get("/packages/#{hex_package}") do
      {:ok, %Response{status_code: 200, body: %{meta: %{links: links}}}} ->
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

  defp reject_blank_values(map) do
    map |> Enum.filter(fn {_key, value} -> is_not_blank(value) end) |> Map.new()
  end

  defp is_not_blank(value) when is_binary(value), do: value != ""
  defp is_not_blank(value), do: !is_nil(value)
end
