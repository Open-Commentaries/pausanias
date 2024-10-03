Mix.install([
  {:data_schema, "~> 0.5.0"},
  {:jason, "~> 1.3"},
  {:saxy, "~> 1.5"},
  {:sweet_xml, "~> 0.7.1"},
  {:toml, "~> 0.7"}
])

defmodule DataSchemas.XPathAccessor do
  @behaviour DataSchema.DataAccessBehaviour

  import SweetXml, only: [sigil_x: 2]

  @impl true

  @doc """
  When a DataSchema asks for the current element (`"."`),
  stringify it and return it to them.

  :xmerl_xml is a callback module from the :xmerl Erlang library.

  It always prepends a header string, hence the call to `tl/1`.
  See https://github.com/kbrw/sweet_xml/pull/45
  """
  def field(data, ".") do
    :xmerl.export_simple([data], :xmerl_xml) |> tl() |> List.to_string()
  end

  def field(data, path) do
    SweetXml.xpath(data, ~x"#{path}"s)
  end

  @impl true
  def list_of(data, path) do
    SweetXml.xpath(data, ~x"#{path}"l)
  end

  @impl true
  def has_one(data, path) do
    SweetXml.xpath(data, ~x"#{path}")
  end

  @impl true
  def has_many(data, path) do
    SweetXml.xpath(data, ~x"#{path}"l)
  end
end

defmodule DataSchemas.Version do
  import DataSchema, only: [data_schema: 1]

  @data_accessor DataSchemas.XPathAccessor
  data_schema(
    field: {:urn, "//body/div[1]/@n", &{:ok, &1}},
    has_one: {:body, "//body", DataSchemas.Version.Body}
  )
end

defmodule DataSchemas.Version.Body do
  import DataSchema, only: [data_schema: 1]

  @data_accessor DataSchemas.XPathAccessor
  data_schema(
    has_many:
      {:books, "//div[@type='textpart' and @subtype='book']", DataSchemas.Version.Body.Book}
  )
end

defmodule DataSchemas.Version.Body.Book do
  import DataSchema, only: [data_schema: 1]

  @data_accessor DataSchemas.XPathAccessor
  data_schema(
    field: {:n, "./@n", &{:ok, &1}},
    has_many:
      {:chapters, "./div[@type='textpart' and @subtype='chapter']",
       DataSchemas.Version.Body.Book.Chapter}
  )
end

defmodule DataSchemas.Version.Body.Book.Chapter do
  import DataSchema, only: [data_schema: 1]

  @data_accessor DataSchemas.XPathAccessor
  data_schema(
    field: {:n, "./@n", &{:ok, &1}},
    has_many:
      {:sections, "./div[@type='textpart' and @subtype='section']",
       DataSchemas.Version.Body.Book.Chapter.Section}
  )
end

defmodule DataSchemas.Version.Body.Book.Chapter.Section do
  import DataSchema, only: [data_schema: 1]

  @data_accessor DataSchemas.XPathAccessor
  data_schema(
    field:
      {:elements, ".",
       fn xml ->
         {:ok, state} =
           Saxy.parse_string(xml, DataSchemas.Version.SaxEventHandler, %{
             element_stack: [],
             text: ""
           })

         {:ok, state.element_stack}
       end},
    field: {:n, "./@n", &{:ok, &1}},
    field: {:raw, ".", &{:ok, &1}},
    field:
      {:text, ".",
       fn xml ->
         {:ok, state} =
           Saxy.parse_string(xml, DataSchemas.Version.SaxEventHandler, %{
             element_stack: [],
             text: ""
           })

         {:ok, String.trim(state.text)}
       end}
  )
end

defmodule DataSchemas.Version.SaxEventHandler do
  require Logger
  @behaviour Saxy.Handler

  def handle_event(:start_document, _prolog, state) do
    {:ok, state}
  end

  def handle_event(:end_document, _data, state) do
    {:ok, %{state | element_stack: state.element_stack |> Enum.reverse()}}
  end

  def handle_event(:start_element, {name, attributes}, state) do
    {:ok, handle_element(name, attributes, state)}
  end

  def handle_event(:end_element, _name, %{element_stack: []} = state), do: {:ok, state}

  def handle_event(:end_element, name, state) do
    [curr | rest] = state.element_stack

    if name == curr.name do
      element_stack = [Map.put(curr, :end_offset, String.length(state.text)) | rest]
      {:ok, %{state | element_stack: element_stack}}
    else
      element_stack = find_and_update_element(name, state)

      {:ok, %{state | element_stack: element_stack}}
    end
  end

  def handle_event(:characters, chars, %{text: ""} = state) do
    {:ok, %{state | text: state.text <> String.trim(chars)}}
  end

  def handle_event(:characters, chars, state) do
    {:ok, %{state | text: state.text <> " " <> String.trim(chars)}}
  end

  defp handle_element("add", attributes, state) do
    element_stack = [
      %{name: "add", start_offset: String.length(state.text), attributes: attributes}
      | state.element_stack
    ]

    %{state | element_stack: element_stack}
  end

  defp handle_element("bibl", attributes, state) do
    element_stack = [
      %{name: "bibl", start_offset: String.length(state.text), attributes: attributes}
      | state.element_stack
    ]

    %{state | element_stack: element_stack}
  end

  defp handle_element("del", attributes, state) do
    element_stack = [
      %{name: "del", start_offset: String.length(state.text), attributes: attributes}
      | state.element_stack
    ]

    %{state | element_stack: element_stack}
  end

  defp handle_element("l", attributes, state) do
    element_stack = [
      %{name: "l", start_offset: String.length(state.text), attributes: attributes}
      | state.element_stack
    ]

    %{state | element_stack: element_stack}
  end

  defp handle_element("milestone", attributes, state) do
    element_stack = [
      %{name: "milestone", start_offset: String.length(state.text), attributes: attributes}
      | state.element_stack
    ]

    %{state | element_stack: element_stack}
  end

  defp handle_element("note", attributes, state) do
    element_stack = [
      %{name: "note", start_offset: String.length(state.text), attributes: attributes}
      | state.element_stack
    ]

    %{state | element_stack: element_stack}
  end

  defp handle_element("quote", attributes, state) do
    element_stack = [
      %{name: "quote", start_offset: String.length(state.text), attributes: attributes}
      | state.element_stack
    ]

    %{state | element_stack: element_stack}
  end

  defp handle_element("seg", attributes, state) do
    element_stack = [
      %{name: "seg", start_offset: String.length(state.text), attributes: attributes}
      | state.element_stack
    ]

    %{state | element_stack: element_stack}
  end

  defp handle_element("term", attributes, state) do
    element_stack = [
      %{name: "term", start_offset: String.length(state.text), attributes: attributes}
      | state.element_stack
    ]

    %{state | element_stack: element_stack}
  end

  defp handle_element("div", _attributes, state) do
    state
  end

  defp handle_element("p", _attributes, state) do
    state
  end

  defp handle_element(name, attributes, state) do
    Logger.warning("Unknown element #{name} with attributes #{inspect(attributes)}.")
    state
  end

  defp find_and_update_element(name, state) do
    element_stack = state.element_stack
    index = element_stack |> Enum.find_index(fn x -> name == x.name end)

    if is_nil(index) do
      element_stack
    else
      el = element_stack |> Enum.at(index)

      element_stack
      |> List.replace_at(index, Map.put(el, :end_offset, String.length(state.text)))
    end
  end
end

defmodule EditionsIngestion do
  @inpath_prefix "tei"
  @outpath_prefix Path.join("out", "editions")

  def run do
    editions_config = File.read!("config/commentary.toml") |> Toml.decode!()

    for edition_config <- editions_config["editions"] do
      f = Path.join(@inpath_prefix, edition_config["filename"])

      File.read!(f)
      |> parse_xml()
      |> unpack()
      |> convert_to_jsonl(f)
    end
  end

  def convert_to_jsonl(blocks, filename) do
    new_f =
      filename
      |> String.replace(@inpath_prefix, @outpath_prefix)
      |> String.replace(Path.extname(filename), ".jsonl")

    unless File.dir?(@outpath_prefix) do
      File.mkdir_p!(@outpath_prefix)
    end

    if File.exists?(new_f) do
      File.rm!(new_f)
    end

    blocks
    |> Enum.with_index()
    |> Enum.each(fn {block, index} ->
      json = block_to_json(block, index)

      File.write!(new_f, Jason.encode!(json) <> "\n", [:append])

      block
      |> Map.get(:elements, [])
      |> inline_elements_to_json(index)
      |> Enum.each(fn e ->
        File.write!(new_f, Jason.encode!(e) <> "\n", [:append])
      end)
    end)
  end

  defp inline_elements_to_json(elements, index) do
    elements
    |> Enum.map(fn element ->
      %{
        attributes: Map.new(element.attributes),
        end_offset: element.end_offset,
        block_index: index,
        start_offset: element.start_offset,
        type: "text_element",
        subtype: element.name
      }
    end)
  end

  defp block_to_json(block, index) do
    %{
      end_offset: Map.get(block, :end_offset),
      index: index,
      location: block.location,
      text: block.text,
      type: "text_container",
      start_offset: Map.get(block, :start_offset),
      subtype: Map.get(block, :name, "div"),
      urn: block.urn
      # words: block.words
    }
  end

  def enumerate_words(text, word_count) do
    words_with_index =
      Regex.split(~r/[[:space:]]|—/, text)
      |> Enum.with_index()

    Enum.reduce(words_with_index, %{offset: 0, current_text: text, words: []}, fn curr, acc ->
      {word, index} = curr

      %{
        offset: current_offset,
        current_text: current_text,
        words: ws
      } = acc

      [left, right] = String.split(current_text, word, parts: 2)
      offset = current_offset + String.length(left)

      w = %{
        xml_id: "word_index_#{index + word_count}",
        offset: offset,
        text: word,
        urn_index: Enum.count(ws, fn w -> w.text == word end) + 1
      }

      %{offset: offset + String.length(word), current_text: right, words: [w | ws]}
    end).words
    |> Enum.reverse()
  end

  def parse_xml(xml) do
    # urn_fragment =
    #   filename
    #   |> String.replace(@inpath_prefix <> "/", "")
    #   |> String.replace(Path.extname(filename), "")

    # urn = "urn:cts:greekLit:#{urn_fragment}"

    {:ok, version} = DataSchema.to_struct(xml, DataSchemas.Version)

    version
    # %{word_count: _word_count, lines: lines} =
    #   version_body.body.lines
    #   |> Enum.reduce(%{word_count: 0, lines: []}, fn line, acc ->
    #     text = line.text |> String.trim()
    #     word_count = acc.word_count

    #     words = enumerate_words(text, word_count)

    #     speaker =
    #       version_body.body.speakers
    #       |> Enum.find(fn speaker -> Enum.member?(speaker.lines, line.n) end)

    #     new_line = %{
    #       elements: [
    #         %{
    #           attributes: %{name: speaker.name},
    #           start_offset: 0,
    #           end_offset: String.length(text),
    #           name: "speaker"
    #         }
    #         | line.elements
    #       ],
    #       location: [line.n],
    #       text: text,
    #       urn: "#{urn}:#{line.n}",
    #       words: words
    #     }

    #     %{word_count: word_count + length(words), lines: [new_line | acc.lines]}
    #   end)

    # Enum.reverse(lines)
  end

  defp block_level_element?(el) do
    el.name in ["list", "quote", "l"]
  end

  @doc """
  The idea is to keep these elements fairly flat here/in the JSONL,
  and then to assemble them into a tree just before rendering. The
  duplication of the text can be useful for debugging in the meantime.
  """
  def unpack(version) do
    urn = version.urn

    version.body.books
    |> Enum.flat_map(fn book ->
      book.chapters
      |> Enum.flat_map(fn chapter ->
        chapter.sections
        |> Enum.flat_map(fn section ->
          location = ["#{book.n}", "#{chapter.n}", "#{section.n}"]

          inline_elements = section.elements |> Enum.reject(&block_level_element?/1)

          block_elements =
            section.elements
            |> Enum.filter(&block_level_element?/1)

          section =
            section
            |> Map.replace(:elements, inline_elements)

          [section | block_elements]
          |> Enum.map(fn b ->
            b
            |> set_location(location)
            |> set_urn("#{urn}:#{location |> Enum.join(".")}")
            |> maybe_set_text(section)
          end)
        end)
      end)
    end)
  end

  defp maybe_set_text(%{start_offset: start_offset, end_offset: end_offset} = block, section)
       when not is_nil(start_offset) do
    Map.put(block, :text, String.slice(section.text, start_offset..end_offset))
  end

  defp maybe_set_text(block, _section), do: block

  defp set_location(block, location) do
    Map.put(block, :location, location)
  end

  defp set_urn(block, urn) do
    Map.put(block, :urn, urn)
  end
end

EditionsIngestion.run()
