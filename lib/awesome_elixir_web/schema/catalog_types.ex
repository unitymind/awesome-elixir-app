defmodule AwesomeElixirWeb.Schema.CatalogTypes do
  use Absinthe.Schema.Notation
  import_types Absinthe.Type.Custom

  alias AwesomeElixirWeb.Resolvers

  @desc "Hold verified uris to github/gitlab source"
  object :git_source do
    @desc "Github uri"
    field :github, :string
    @desc "Gitlab uri"
    field :gitlab, :string
  end

  @desc "Describes project included in Awesome Elixir curated list"
  object :item do
    field :id, :id
    field :name, :string
    field :description, :string
    field :stars_count, :integer
    field :updated_in, :integer
    field :url, :string
    field :git_source, :git_source
    field :is_dead, :boolean
    field :is_scrapped, :boolean
    field :pushed_at, :datetime
    field :inserted_at, :naive_datetime
    field :updated_at, :naive_datetime
  end

  @desc "Describes project's category included in Awesome Elixir curated list"
  object :category do
    field :id, :id
    field :name, :string
    field :description, :string
    field :slug, :string
    field :items, list_of(:item)
    field :inserted_at, :naive_datetime
    field :updated_at, :naive_datetime
  end

  @desc "Hold result of `listCategory` query"
  object :categories do
    @desc "List of fetched Category entities"
    field :entities, list_of(:category)
    field :categories_count, :integer
    field :items_count, :integer
    field :last_updated_at, :naive_datetime
  end

  @desc "Supporting Enum for `minStars` `listCategory` query argument"
  enum :min_stars_values do
    value :all, as: "all"
    value :s_10, as: "10"
    value :s_50, as: "50"
    value :s_100, as: "100"
    value :s_500, as: "500"
    value :s_1000, as: "1000"
  end

  object :catalog_queries do
    @desc "Fetch list of `Category` entities filtered according to args"
    field :list_categories, :categories do
      @desc "Minimal `starsCount` of `Item`s"
      arg :min_stars, :min_stars_values
      @desc "Include unstarred `Item`"
      arg :show_unstarred, :boolean
      @desc "Hide outdated `Item`s"
      arg :hide_outdated, :boolean
      @desc "Sho only just updated `Item`s"
      arg :show_just_updated, :boolean

      resolve &Resolvers.list_categories/2
    end
  end
end
