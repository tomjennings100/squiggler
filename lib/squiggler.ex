defmodule Squiggler do
  require Logger
  @moduledoc """
  Documentation for Squiggler.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Squiggler.hello
      :world

  """

  def main do
    load_image()
    |> convert_to_bw
    |> build_squiggles
    |> build_svg
    |> write_file
  end

  def load_image do 
    Logger.debug('Loading image...')
    {:ok, image} = Imagineer.load('./image.png')
    Logger.debug('Image loaded...')
    image
  end

  def convert_to_bw(image) do
    Logger.debug('converting to black and white...')
    IO.puts('Height: #{image.height} \nWidth: #{image.width}\nRatio:#{image.width/image.height}')
    Enum.take_every(image.pixels, 10)
    |> Enum.map(fn row -> 
         Enum.map(row, fn {r,_g,_b,_a} -> r end)
      end)
  end
  
  def build_squiggles(rows) do 
    rows 
    |> Enum.with_index
    |> Enum.map(fn {row, idx} ->
      row_data = row |> Enum.reduce("", fn(v, acc) ->  acc <> " " <> Integer.to_string(v) end)
      ~s(<path d="M 0, #{10 * idx} q#{row_data}" style="fill:none;stroke-width:0.9;stroke-linecap:round;stroke-miterlimit:10;stroke-dasharray:none"/>)
    end)
  end

  def build_svg(squiggles) do
    svg = {:svg,
           %{
             viewBox: "0 0 1000 1000",
             xmlns: "http://www.w3.org/2000/svg",
             style: "font-style:normal;font-weight:normal;font-size:12px;font-family:Dialog;color-interpolation:auto;fill:#000000;fill-opacity:1;stroke:#000000;stroke-width:1;stroke-linecap:square;stroke-linejoin:miter;stroke-miterlimit:10;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1;color-rendering:auto;image-rendering:auto;shape-rendering:auto;text-rendering:auto",
             width: 1000,
             height: 1000,
             "xml:space": "preserve"
           },
           squiggles}
    |> XmlBuilder.generate
  end

  def write_file(svg) do
    {:ok, file} = File.open('./image.svg', [:write])
    IO.binwrite(file, svg)
    File.close(file)
  end
end
