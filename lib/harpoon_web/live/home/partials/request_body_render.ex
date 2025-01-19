defmodule HarpoonWeb.Home.Partials.RequestBodyRender do
  @moduledoc false
  use Phoenix.Component

  alias Harpoon.Requests.Request

  @images_types ~w(jpg jpeg png)

  attr :data, :list, required: true

  def request_body_content(assigns) do
    case Request.get_file_type(assigns.data) do
      {:ok, type} ->
        assigns
        |> assign(:type, to_string(type))
        |> request_body_content_by_type()

      {:error, _} ->
        invalid_request_body_content(assigns)
    end
  end

  attr :type, :string, required: true
  attr :data, :list, required: true

  defp request_body_content_by_type(%{type: "json"} = assigns) do
    ~H"""
    <pre class="language-json" readonly disabled>
      <code id="request-body" class="rounded-lg border border-gray-300 dark:border-gray-600">
      {@data}
      </code>
    </pre>
    """
  end

  defp request_body_content_by_type(%{type: "xml"} = assigns) do
    ~H"""
    <pre class="language-xml" readonly disabled>
      <code id="request-body" class="rounded-lg border border-gray-300 dark:border-gray-600">
      {Phoenix.HTML.html_escape(@data)}
      </code>
    </pre>
    """
  end

  defp request_body_content_by_type(%{type: "html"} = assigns) do
    ~H"""
    <pre class="language-html" readonly disabled>
      <code id="request-body" class="rounded-lg border border-gray-300 dark:border-gray-600">
      {Phoenix.HTML.html_escape(@data)}
      </code>
    </pre>
    """
  end

  defp request_body_content_by_type(%{type: "text"} = assigns) do
    ~H"""
    <pre class="language" readonly disabled>
      <code id="request-body" class="rounded-lg border border-gray-300 dark:border-gray-600">
      {@data}
      </code>
    </pre>
    """
  end

  defp request_body_content_by_type(%{type: type, data: data} = assigns) when type in @images_types do
    image_src = "data:image/#{type};base64,#{Base.encode64(data)}"
    assigns = assign(assigns, image_src: image_src)

    ~H"""
    <img
      class="h-auto max-w-xl rounded-lg shadow-xl dark:shadow-gray-800"
      src={@image_src}
      alt="a random image"
    />
    """
  end

  defp request_body_content_by_type(%{type: "pdf", data: data} = assigns) do
    pdf_src = "data:application/pdf;base64,#{Base.encode64(data)}"
    assigns = assign(assigns, pdf_src: pdf_src)

    ~H"""
    <embed src={@pdf_src} style="min-height:100vh;width:100%" class="my-2" />
    """
  end

  defp request_body_content_by_type(assigns) do
    ~H"""
    <p id="floating_helper_text" class="my-2 text-xl text-gray-500 dark:text-gray-400">
      {@type} is a valid type, but misses a proper render strategy.
    </p>
    """
  end

  def invalid_request_body_content(assigns) do
    ~H"""
    <p id="floating_helper_text" class="my-2 text-xl text-gray-500 dark:text-gray-400">
      Invalid Body Content.
    </p>
    """
  end
end
