{#
  Fabric T-SQL bracket escaping helper.
  T-SQL requires square brackets around identifiers with special characters,
  Norwegian letters, spaces, or reserved words.
  Inside brackets, the only escaped character is ']' -> ']]'.
#}
{% macro escape_column(col_name) -%}
    [{{ col_name | replace(']', ']]') }}]
{%- endmacro %}
