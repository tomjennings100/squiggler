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
    {:ok, image} = Imagineer.load('./image2.png')
    Logger.debug('Image loaded...')
    image
  end

  def convert_to_bw(image) do
    Logger.debug('converting to black and white...')
    IO.puts('Height: #{image.height} \nWidth: #{image.width}\nRatio:#{image.width/image.height}')
    Enum.take_every(image.pixels, 5)
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
      |> Enum.reduce("", fn({lum, col_idx}, acc) ->  acc <> " " <> gen_sine_bezier(lum, row_idx * 50, col_idx * 10) end)
      ~s(<path d="#{row_data}" style="fill:none;stroke-width:1.2;"/>)
    end)
  end

  def gen_sine_bezier(lum, row_idx, col_idx) do
    amplitude = 2
    ~s( M #{col_idx}, #{row_idx}
        C #{col_idx}, #{row_idx}
          #{col_idx + 5}, #{row_idx + (255 - lum)/3}
          #{col_idx + 5}, #{row_idx}
        S #{col_idx + 10}, #{row_idx + (255 - lum)/3}
          #{col_idx + 10}, #{row_idx}
        )
  end

  def build_svg(squiggles) do
        {:svg,
           %{
             viewBox: "0 0 5540 4910",
             xmlns: "http://www.w3.org/2000/svg",
             style: "fill:#000000;fill-opacity:1;stroke:#000000;stroke-width:1;",
             width: 5540,
             height: 2910,
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