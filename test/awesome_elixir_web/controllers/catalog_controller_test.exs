defmodule AwesomeElixirWeb.CatalogControllerTest do
  use AwesomeElixirWeb.ConnCase, async: true
  alias AwesomeElixir.Catalog

  describe "With empty dataset" do
    setup do
      Catalog.invalidate_cached()
      :ok
    end

    test "GET /", %{conn: conn} do
      get_catalog_parsed_html(conn)
      |> assert_nav_links()
      |> assert_input_hidden_min_stars()
      |> assert_counters(items: 0, categories: 0)
      |> assert_last_updated(:never)
    end

    test "GET /?show_unstarred=true&hide_outdated=true&show_just_updated=true", %{conn: conn} do
      get_catalog_parsed_html(conn,
        show_unstarred: true,
        hide_outdated: true,
        show_just_updated: true
      )
      |> assert_nav_links(%{show_unstarred: true, hide_outdated: true, show_just_updated: true})
      |> assert_input_hidden_min_stars()
      |> assert_counters(items: 0, categories: 0)
      |> assert_input_checkbox(3)
      |> assert_last_updated(:never)
    end
  end

  describe "With dataset" do
    setup do
      [category_1, category_2, category_3, category_4, category_5] = insert_list(5, :category)

      items = %{
        scraped_starred_5:
          insert(:scraped_item, stars_count: 5, updated_in: 14, category_id: category_1.id),
        scraped_starred_10:
          insert(:scraped_item, stars_count: 10, updated_in: 14, category_id: category_1.id),
        scraped_starred_50:
          insert(:scraped_item, stars_count: 50, updated_in: 14, category_id: category_2.id),
        scraped_starred_100:
          insert(:scraped_item, stars_count: 100, updated_in: 14, category_id: category_3.id),
        scraped_starred_500:
          insert(:scraped_item, stars_count: 500, updated_in: 14, category_id: category_4.id),
        scraped_starred_1000:
          insert(:scraped_item, stars_count: 1000, updated_in: 14, category_id: category_5.id),
        scraped_starred_outdated:
          insert(:scraped_item, stars_count: 50, updated_in: 380, category_id: category_1.id),
        scraped_starred_just_updated:
          insert(:scraped_item, stars_count: 100, updated_in: 6, category_id: category_2.id),
        scraped: insert(:scraped_item, category_id: category_1.id)
      }

      Catalog.invalidate_cached()

      [items: items]
    end

    test "GET /", %{conn: conn, items: items} do
      get_catalog_parsed_html(conn)
      |> assert_nav_links()
      |> assert_input_hidden_min_stars()
      |> assert_counters(items: 8, categories: 5)
      |> assert_input_checkbox(0)
      |> assert_outdated(1)
      |> assert_item_links(items, Map.keys(items) -- [:scraped])
      |> assert_last_updated()
    end

    test "GET /min_stars=10", %{conn: conn, items: items} do
      get_catalog_parsed_html(conn, min_stars: "10")
      |> assert_nav_links()
      |> assert_input_hidden_min_stars(10)
      |> assert_counters(items: 7, categories: 5)
      |> assert_input_checkbox(0)
      |> assert_outdated(1)
      |> assert_item_links(items, Map.keys(items) -- ~w(scraped_starred_5 scraped)a)
      |> assert_last_updated()
    end

    test "GET /min_stars=50", %{conn: conn, items: items} do
      get_catalog_parsed_html(conn, min_stars: "50")
      |> assert_nav_links()
      |> assert_input_hidden_min_stars(50)
      |> assert_counters(items: 6, categories: 5)
      |> assert_input_checkbox(0)
      |> assert_outdated(1)
      |> assert_item_links(
        items,
        Map.keys(items) -- ~w(scraped_starred_5 scraped_starred_10 scraped)a
      )
      |> assert_last_updated()
    end

    test "GET /min_stars=100", %{conn: conn, items: items} do
      get_catalog_parsed_html(conn, min_stars: "100")
      |> assert_nav_links()
      |> assert_input_hidden_min_stars(100)
      |> assert_counters(items: 4, categories: 4)
      |> assert_input_checkbox(0)
      |> assert_outdated(0)
      |> assert_item_links(
        items,
        Map.keys(items) --
          ~w(scraped_starred_5 scraped_starred_10 scraped_starred_50 scraped_starred_outdated scraped)a
      )
      |> assert_last_updated()
    end

    test "GET /min_stars=500", %{conn: conn, items: items} do
      get_catalog_parsed_html(conn, min_stars: "500")
      |> assert_nav_links()
      |> assert_input_hidden_min_stars(500)
      |> assert_counters(items: 2, categories: 2)
      |> assert_input_checkbox(0)
      |> assert_outdated(0)
      |> assert_item_links(items, [:scraped_starred_1000, :scraped_starred_500])
      |> assert_last_updated()
    end

    test "GET /min_stars=500&show_just_updated=true", %{conn: conn} do
      get_catalog_parsed_html(conn, min_stars: "500", show_just_updated: true)
      |> assert_nav_links(%{show_just_updated: true})
      |> assert_input_hidden_min_stars(500)
      |> assert_counters(items: 0, categories: 0)
      |> assert_input_checkbox(1)
      |> assert_input_checkbox("showJustUpdated")
      |> assert_last_updated()
    end

    test "GET /min_stars=1000", %{conn: conn, items: items} do
      get_catalog_parsed_html(conn, min_stars: "1000")
      |> assert_nav_links()
      |> assert_input_hidden_min_stars(1000)
      |> assert_counters(items: 1, categories: 1)
      |> assert_input_checkbox(0)
      |> assert_outdated(0)
      |> assert_item_links([items.scraped_starred_1000])
      |> assert_last_updated()
    end

    test "GET /hide_outdated=true", %{conn: conn, items: items} do
      get_catalog_parsed_html(conn, hide_outdated: true)
      |> assert_nav_links(%{hide_outdated: true})
      |> assert_input_hidden_min_stars()
      |> assert_counters(items: 7, categories: 5)
      |> assert_input_checkbox(1)
      |> assert_input_checkbox("hideOutdated")
      |> assert_outdated(0)
      |> assert_item_links(
        items,
        Map.keys(items) -- ~w(scraped scraped_starred_outdated)a
      )
    end

    test "GET /?show_unstarred=true", %{conn: conn, items: items} do
      get_catalog_parsed_html(conn, show_unstarred: true)
      |> assert_nav_links(%{show_unstarred: true})
      |> assert_input_hidden_min_stars()
      |> assert_counters(items: 9, categories: 5)
      |> assert_input_checkbox(1)
      |> assert_input_checkbox("showUnstarred")
      |> assert_outdated(1)
      |> assert_item_links(items)
    end

    test "GET /?show_unstarred=true&hide_outdated=true", %{conn: conn, items: items} do
      get_catalog_parsed_html(conn, show_unstarred: true, hide_outdated: true)
      |> assert_nav_links(%{show_unstarred: true, hide_outdated: true})
      |> assert_input_hidden_min_stars()
      |> assert_counters(items: 8, categories: 5)
      |> assert_input_checkbox(2)
      |> assert_input_checkbox(~w(showUnstarred hideOutdated))
      |> assert_outdated(0)
      |> assert_item_links(items, Map.keys(items) -- [:scraped_starred_outdated])
    end

    test "GET /show_just_updated=true", %{conn: conn, items: items} do
      get_catalog_parsed_html(conn, show_just_updated: true)
      |> assert_nav_links(%{show_just_updated: true})
      |> assert_input_hidden_min_stars()
      |> assert_counters(items: 1, categories: 1)
      |> assert_input_checkbox(1)
      |> assert_input_checkbox("showJustUpdated")
      |> assert_outdated(0)
      |> assert_item_links(
        items,
        [:scraped_starred_just_updated]
      )
    end

    test "GET /show_unstarred=true&show_just_updated=true", %{conn: conn, items: items} do
      get_catalog_parsed_html(conn, show_unstarred: true, show_just_updated: true)
      |> assert_nav_links(%{show_unstarred: true, show_just_updated: true})
      |> assert_input_hidden_min_stars()
      |> assert_counters(items: 2, categories: 2)
      |> assert_input_checkbox(2)
      |> assert_input_checkbox(~w(showUnstarred showJustUpdated))
      |> assert_outdated(0)
      |> assert_item_links(
        items,
        [:scraped, :scraped_starred_just_updated]
      )
    end
  end

  defp get_catalog_parsed_html(conn, opts \\ []) do
    get(conn, "/", opts) |> html_response(200) |> Floki.parse()
  end

  defp assert_last_updated(html) do
    "Last updated at: " <> last_updated_at = Floki.find(html, "#lastUpdateAt") |> Floki.text()
    assert %NaiveDateTime{} = NaiveDateTime.from_iso8601!(last_updated_at)
    html
  end

  defp assert_last_updated(html, :never) do
    assert Floki.find(html, "#lastUpdateAt") |> Floki.text() == "Last updated at: never"
    html
  end

  defp assert_counters(html, items: items, categories: categories) do
    assert Floki.find(html, "#totalCounters") |> Floki.text() ==
             "Total items: #{items} (in #{categories} categories)"

    html
  end

  defp assert_nav_links(html, filters \\ %{}) do
    filters =
      Map.merge(%{show_unstarred: false, hide_outdated: false, show_just_updated: false}, filters)

    for link <- get_links_for(html, :nav), {key, value} <- filters do
      assert link =~ "#{key}=#{value}"
    end

    html
  end

  defp assert_item_links(html, items, keys) when is_map(items) and is_list(keys) do
    items = for key <- keys, do: Map.get(items, key)
    assert_item_links(html, items)
  end

  defp assert_item_links(html, items) when is_map(items),
    do: assert_item_links(html, Map.values(items))

  defp assert_item_links(html, items) when is_list(items) do
    links = get_links_for(html, :item)
    for %{url: url} <- items, do: assert(Enum.member?(links, url))
    html
  end

  defp assert_outdated(html, count) do
    assert Floki.find(html, "li.outdated") |> length == count
    html
  end

  def assert_input_hidden_min_stars(html, min_stars \\ "all") do
    assert Floki.find(html, "input[type=hidden][name=min_stars][value=#{min_stars}") |> length ==
             1

    html
  end

  defp assert_input_checkbox(html, checked_count) when is_integer(checked_count) do
    assert Floki.find(html, "input[type=checkbox][checked]") |> length == checked_count
    html
  end

  defp assert_input_checkbox(html, input_ids) when is_list(input_ids) do
    for input_id <- input_ids, do: assert_input_checkbox(html, input_id)
    html
  end

  defp assert_input_checkbox(html, input_id) when is_binary(input_id) do
    assert Floki.find(html, "input[id=#{input_id}][type=checkbox][checked]") |> length == 1
    html
  end

  defp get_links_for(html, kind) when kind in ~w(item nav)a do
    Floki.find(html, "a.#{kind}-link") |> Floki.attribute("href")
  end
end
