defmodule AwesomeElixir.Factory do
  use ExMachina.Ecto, repo: AwesomeElixir.Repo
  alias AwesomeElixir.Catalog.{Category, Item}

  def category_factory do
    name = Faker.random_between(2, 3) |> Faker.Lorem.sentence("")

    %Category{
      name: name,
      slug: String.downcase(name) |> String.split() |> Enum.join("-"),
      description: Faker.Lorem.sentence()
    }
  end

  def item_factory do
    %Item{
      name: Faker.Lorem.word(),
      description: Faker.Lorem.sentence(),
      url: Faker.Internet.url()
    }
  end
end
