defmodule AwesomeElixir.Scrapper.Index do
  alias AwesomeElixir.Scrapper
  alias Earmark.{Block, Parser}

  defmodule Category do
    defstruct name: nil, slug: nil, description: nil, items: []

    @type t :: %__MODULE__{
            name: String.t(),
            slug: String.t(),
            description: String.t(),
            items: [AwesomeElixir.Scrapper.Index.Item.t()]
          }
  end

  defmodule Item do
    defstruct name: nil, url: nil, description: nil
    @type t :: %__MODULE__{name: String.t(), url: String.t(), description: String.t()}
  end

  def update do
    fetch() |> update_flow() |> Scrapper.store_data()
    :ok
  end

  def update_from_file(path) do
    case File.read(path) do
      {:ok, content} ->
        update_flow(content) |> Scrapper.store_data()
        :ok

      _ ->
        :error
    end
  end

  defp update_flow(content) do
    content |> parse_markdown() |> extract_data()
  end

  defp fetch do
    case HTTPoison.get("https://raw.githubusercontent.com/h4cc/awesome-elixir/master/README.md") do
      {:ok, %HTTPoison.Response{body: content}} -> content
      _ -> :error
    end
  end

  defp parse_markdown(raw_markdown) do
    {markdown_blocks, _} = Parser.parse_markdown(raw_markdown)
    markdown_blocks
  end

  defp extract_data(parsed_markdown) do
    parsed_markdown
    |> extract_categories()
    |> enrich_categories(parsed_markdown)
  end

  defp extract_categories(parsed_markdown) do
    Enum.reduce_while(parsed_markdown, [], &reducer_find_categories/2)
    |> Stream.map(&build_category_from_block_list_item/1)
    |> Stream.map(fn category ->
      {category.name, category}
    end)
    |> Enum.into(%{})
  end

  defp reducer_find_categories(markdown_block, result) do
    case markdown_block do
      %Block.List{
        blocks: [
          %Block.ListItem{
            blocks: [
              %Block.Para{lines: ["[Awesome Elixir](#awesome-elixir)"]},
              %Block.List{blocks: categories} | _
            ]
          }
          | _
        ]
      } ->
        {:halt, categories}

      _ ->
        {:cont, result}
    end
  end

  defp build_category_from_block_list_item(list_item) do
    %Block.ListItem{blocks: [%Block.Para{lines: [category_line | _]}]} = list_item
    [name, slug] = String.split(category_line, "](#")
    %Category{name: String.replace(name, ~r/^\[/, ""), slug: String.replace(slug, ~r/\)$/, "")}
  end

  defp enrich_categories(categories, parsed_markdown) do
    Enum.reduce(
      parsed_markdown,
      %{
        categories: categories,
        current_category_key: nil,
        current_category: nil,
        grab_category_description: false,
        grab_category_items: false
      },
      &reducer_enrich_category/2
    ).categories
  end

  defp reducer_enrich_category(%Block.Heading{content: category_name, level: 2}, enrich_state) do
    case Map.fetch(enrich_state.categories, category_name) do
      {:ok, category} ->
        case enrich_state.current_category do
          nil ->
            %{
              enrich_state
              | current_category_key: category_name,
                current_category: category,
                grab_category_description: true,
                grab_category_items: false
            }

          _ ->
            %{
              enrich_state
              | categories:
                  Map.replace!(
                    enrich_state.categories,
                    enrich_state.current_category_key,
                    enrich_state.current_category
                  ),
                current_category_key: category_name,
                current_category: category,
                grab_category_description: true,
                grab_category_items: false
            }
        end

      :error ->
        enrich_state
    end
  end

  defp reducer_enrich_category(%Block.Para{lines: [category_description | _]}, enrich_state) do
    if enrich_state.grab_category_description do
      %{
        enrich_state
        | current_category: %Category{
            enrich_state.current_category
            | description: String.replace(category_description, ~r/^\*|\*$/, "")
          },
          grab_category_description: false,
          grab_category_items: true
      }
    else
      enrich_state
    end
  end

  defp reducer_enrich_category(%Block.List{blocks: item_blocks}, enrich_state) do
    if enrich_state.grab_category_items do
      %{
        enrich_state
        | current_category: %Category{
            enrich_state.current_category
            | items: Enum.map(item_blocks, &build_item_from_block_list_item/1)
          },
          grab_category_description: false,
          grab_category_items: false
      }
    else
      enrich_state
    end
  end

  defp reducer_enrich_category(_, enrich_state), do: enrich_state

  defp build_item_from_block_list_item(list_item) do
    %Block.ListItem{blocks: [%Block.Para{lines: [item_line | _]}]} = list_item
    [name_url, description] = String.split(item_line, ") - ")
    [name, url] = String.split(name_url, "](")
    %Item{name: String.replace(name, ~r/^\[/, ""), url: url, description: description}
  end
end
