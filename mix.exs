defmodule Sym.Mixfile do
  use Mix.Project

  def project do
    [
      app: :sym,
      version: "0.0.1",
      elixir: "~> 1.4",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      description: description(),
      package: package(),
      deps: deps()
    ]
  end
  
  defp description do
    """
    A Symbolic Logic library.
    """
  end
  
  defp package do
    [
      files: ["lib", "mix.exs", "README.md"],
      maintainers: ["Connor Stauffer"],
      licenses: ["UNLICENSED"],
      links: %{
        "GitHub" => "https://github.com/connorpaulstauffer/sym",
        "Docs" => "http://hexdocs.pm/sym/"
      }
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:ex_doc, "~> 0.11", only: :dev},
      {:earmark, "~> 0.1", only: :dev},
      {:neotomex, "~> 0.1.6"}
    ]
  end
end
