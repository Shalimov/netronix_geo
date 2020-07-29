defmodule NetronixGeo.Authorize do
  @moduledoc """
  Module defines simple macro to reduce boilierplate of authorization checks
  and do in a declarative way
  """

  @doc """
  Macro generates function already wrapped in authorization checker
  """
  defmacro defauth(func_decl, extras, do: body) do
    {func_name, args} =
      case func_decl do
        {:when, _code, [{func_name, _fcode, args}, _in_clause]} -> {func_name, args}
        {func_name, _code, args} -> {func_name, args}
      end

    policy = Keyword.get(extras, :policy)
    action = Keyword.get(extras, :for, func_name)

    destructure([user_arg], args)

    protected =
      quote do
        with :ok <- Bodyguard.permit(unquote(policy), unquote(action), var!(unquote(user_arg))) do
          unquote(body)
        end
      end

    quote do
      def(unquote(func_decl), do: unquote(protected))
    end
  end
end
