defmodule AwesomeElixir.Scrapper.Item do
  alias AwesomeElixir.Catalog.Item
  alias AwesomeElixir.Repo
  alias AwesomeElixir.Scrapper.{GithubApi, GitlabApi, HexpmApi}
  alias HTTPoison.Response

  def update(%Item{github: github} = item) when not is_nil(github) do
    case GithubApi.get("/repos/" <> github) do
      {:ok,
       %Response{
         status_code: 200,
         body: %{pushed_at: pushed_at, watchers: stars_count, description: description}
       }} ->
        item
        |> Item.insert_or_update_changeset(%{
          stars_count: stars_count,
          pushed_at: pushed_at,
          description: description,
          is_scrapped: true
        })
        |> Repo.update()

      {:ok, %Response{status_code: 404}} ->
        item
        |> Item.insert_or_update_changeset(%{is_dead: true, is_scrapped: true})
        |> Repo.update()

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

  def update(%Item{gitlab: gitlab} = item) when not is_nil(gitlab) do
    case GitlabApi.get("/projects/" <> URI.encode_www_form(gitlab)) do
      {:ok,
       %Response{
         status_code: 200,
         body: %{star_count: stars_count, last_activity_at: pushed_at}
       }} ->
        item
        |> Item.insert_or_update_changeset(%{
          stars_count: stars_count,
          pushed_at: pushed_at,
          is_scrapped: true
        })
        |> Repo.update()

      {:ok, %Response{status_code: 404}} ->
        item
        |> Item.insert_or_update_changeset(%{is_dead: true, is_scrapped: true})
        |> Repo.update()

      _ ->
        {:retry, :now}
    end
  end

  def update(%Item{url: "https://hex.pm" <> hex_package} = item) do
    case Repo.update(
           item
           |> Item.insert_or_update_changeset(extract_repo_from_hexpm(hex_package))
         ) do
      {:error, _} -> :error
      {:ok, _} -> {:retry, :now}
    end
  end

  def update(%Item{url: url} = item) when is_binary(url) do
    case HTTPoison.get(url, [], follow_redirect: true) do
      {:ok, %Response{status_code: 200}} ->
        item
        |> Item.insert_or_update_changeset(%{is_dead: false, is_scrapped: true})
        |> Repo.update()

      {:ok, %Response{status_code: 404}} ->
        item
        |> Item.insert_or_update_changeset(%{is_dead: true, is_scrapped: true})
        |> Repo.update()

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
           pushed_at: pushed_at,
           watchers: starts_count,
           html_url: "https://github.com/" <> github
         }
       }} ->
        item
        |> Item.insert_or_update_changeset(%{
          stars_count: starts_count,
          pushed_at: pushed_at,
          github: github,
          is_scrapped: true
        })
        |> Repo.update()

      _ ->
        {:retry, :now}
    end
  end

  defp extract_repo_from_hexpm(hex_package) do
    case HexpmApi.get(hex_package) do
      {:ok, %Response{status_code: 200, body: %{meta: %{links: links}}}} ->
        Enum.reduce(Map.values(links), %{}, &extract_from_hexpm_link/2)

      _ ->
        %{}
    end
  end

  defp extract_from_hexpm_link(link, repos) do
    case link do
      "https://github.com/" <> rest -> Map.put(repos, :github, rest)
      "https://gitlab.com/" <> rest -> Map.put(repos, :gitlab, rest)
      _ -> repos
    end
  end
end
