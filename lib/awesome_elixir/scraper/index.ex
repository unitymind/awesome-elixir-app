defmodule AwesomeElixir.Scraper.Index do
  alias Earmark.{Block, Parser}

  # coveralls-ignore-start
  defmodule Category do
    use TypedStruct

    typedstruct do
      field :name, String.t(), enforce: true
      field :slug, String.t(), enforce: true
      field :description, String.t()
      field :items, {:array, AwesomeElixir.Scraper.Index.Item.t()}
    end
  end

  defmodule Item do
    use TypedStruct

    typedstruct enforce: true do
      field :name, String.t()
      field :url, String.t()
      field :description, String.t()
    end
  end

  # coveralls-ignore-stop

  @spec update() ::
          [__MODULE__.Category.t()]
          | {:error, HTTPoison.Error.t()}
  def update do
    with content when is_binary(content) <- fetch(),
         data when is_map(data) <- update_flow(content) do
      data |> Map.values()
    end
  end

  defp update_flow(raw_markdown) do
    raw_markdown |> parse_markdown() |> extract_data()
  end

  defp fetch do
    with {:ok, %HTTPoison.Response{body: content, status_code: 200}} <-
           HTTPoison.get("https://raw.githubusercontent.com/h4cc/awesome-elixir/master/README.md") do
      content
    end
  end

  defp parse_markdown(raw_markdown) do
    with {markdown_blocks, _} <- Parser.parse_markdown(raw_markdown) do
      markdown_blocks
    end
  end

  defp extract_data(markdown_blocks) do
    markdown_blocks
    |> extract_categories()
    |> enrich_categories()
  end

  defp extract_categories(markdown_blocks) do
    categories =
      Enum.reduce_while(markdown_blocks, [], &reducer_find_categories/2)
      |> Stream.map(&build_category_from_block_list_item/1)
      |> Stream.map(fn category ->
        {category.name, category}
      end)
      |> Enum.into(%{})

    {categories, markdown_blocks}
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

  defp enrich_categories({categories, markdown_blocks}) do
    Enum.reduce(
      markdown_blocks,
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

  defp reducer_enrich_category(
         %Block.Heading{content: category_name, level: 2},
         enrich_state
       ) do
    case enrich_state do
      %{categories: %{^category_name => category}} ->
        %{
          enrich_state
          | current_category_key: category_name,
            current_category: category,
            grab_category_description: true,
            grab_category_items: false
        }

      _ ->
        enrich_state
    end
  end

  defp reducer_enrich_category(
         %Block.Para{lines: [category_description | _]},
         %{grab_category_description: true} = enrich_state
       ) do
    current_category = %Category{
      enrich_state.current_category
      | description: String.replace(category_description, ~r/^\*|\*$/, "")
    }

    %{
      enrich_state
      | categories:
          Map.replace!(
            enrich_state.categories,
            enrich_state.current_category_key,
            current_category
          ),
        current_category: current_category,
        grab_category_description: false,
        grab_category_items: true
    }
  end

  defp reducer_enrich_category(
         %Block.List{blocks: item_blocks},
         %{grab_category_items: true} = enrich_state
       ) do
    current_category = %Category{
      enrich_state.current_category
      | items: Enum.map(item_blocks, &build_item_from_block_list_item/1)
    }

    %{
      enrich_state
      | categories:
          Map.replace!(
            enrich_state.categories,
            enrich_state.current_category_key,
            current_category
          ),
        current_category: current_category,
        grab_category_description: false,
        grab_category_items: false
    }
  end

  defp reducer_enrich_category(_, enrich_state), do: enrich_state

  defp build_item_from_block_list_item(list_item) do
    %Block.ListItem{blocks: [%Block.Para{lines: [item_line | _]}]} = list_item
    [name_url, description] = String.split(item_line, ") - ")
    [name, url] = String.split(name_url, "](")
    %Item{name: String.replace(name, ~r/^\[/, ""), url: url, description: description}
  end
end
