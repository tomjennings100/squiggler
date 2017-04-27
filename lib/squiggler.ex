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
    {:ok, image} = Imagineer.load('./image1.png')
    Logger.debug('Image loaded...')
    image
  end

  def convert_to_bw(image) do
    Logger.debug('converting to black and white...')
    IO.puts('Height: #{image.height} \nWidth: #{image.width}\nRatio:#{image.width/image.height}')
    Enum.take_every(image.pixels, 10)
    |> Enum.map(fn row -> 
         Enum.map(row, fn {r,g,b} -> div((r + g + b), 3) end)
      end)
  end
  
  def build_squiggles(rows) do 
    rows 
    |> Enum.with_index
    |> Enum.map(fn {row, row_idx} ->
      row_data = row 
      |> Enum.with_index
      |> Enum.reduce("", fn({lum, col_idx}, acc) ->  acc <> " " <> gen_sine_bezier(lum, row_idx, col_idx) end)
      ~s(<path d="#{row_data}" style="fill:none;stroke-width:0.2;stroke-linecap:round;stroke-miterlimit:10;stroke-dasharray:none"/>)
    end)
  end

  def gen_sine_bezier(lum, row_idx, col_idx) do
    ~s( M  #{col_idx}, #{row_idx * 10}
        C #{col_idx}, #{(row_idx * 10) + div(lum, 5)}
          #{(col_idx) + 10}, #{(row_idx * 10) + div(lum, 5)}
          #{(col_idx + 10) + 10}, #{(row_idx * 10)}
        )
  end

  def build_svg(squiggles) do
        {:svg,
           %{
             viewBox: "0 0 554 491",
             xmlns: "http://www.w3.org/2000/svg",
             style: "font-style:normal;font-weight:normal;font-size:12px;font-family:Dialog;color-interpolation:auto;fill:#000000;fill-opacity:1;stroke:#000000;stroke-width:1;stroke-linecap:square;stroke-linejoin:miter;stroke-miterlimit:10;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1;color-rendering:auto;image-rendering:auto;shape-rendering:auto;text-rendering:auto",
             width: 554,
             height: 291,
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