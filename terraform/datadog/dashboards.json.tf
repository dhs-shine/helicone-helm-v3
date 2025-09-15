resource "datadog_dashboard_json" "hql_overview" {
  dashboard = <<JSON
{
  "title": "HQL Overview",
  "description": "Comprehensive monitoring of Helicone Query Language operations with detailed performance metrics and error tracking.",
  "layout_type": "ordered",
  "template_variables": [
    { "name": "env", "prefix": "env", "default": "*" },
    { "name": "organizationId", "prefix": "@organizationId", "default": "*" }
  ],
  "widgets": [
    {
      "definition": {
        "type": "note",
        "content": "## HQL Controller Operations\nMonitoring controller-level traces for HQL endpoints",
        "background_color": "gray",
        "font_size": "14",
        "text_align": "center",
        "show_tick": false
      }
    },
    {
      "definition": {
        "type": "timeseries",
        "title": "HQL Request Volume by Operation",
        "show_legend": true,
        "legend_layout": "horizontal",
        "legend_columns": ["avg", "max", "value"],
        "requests": [
          {
            "display_type": "bars",
            "style": {"palette": "dog_classic"},
            "apm_query": {
              "index": "trace-search",
              "search": {"query": "env:$env @organizationId:$organizationId service:helicone-sql (name:hql.controller.executeSql OR name:hql.controller.getClickHouseSchema OR name:hql.controller.downloadCsv)"},
              "compute": {"aggregation": "count"},
              "group_by": [{"facet": "name", "limit": 10}]
            }
          }
        ]
      }
    },
    {
      "definition": {
        "type": "timeseries",
        "title": "HQL Query Latency Distribution (p50, p95, p99)",
        "show_legend": true,
        "legend_layout": "horizontal",
        "requests": [
          {
            "display_type": "line",
            "style": {"palette": "cool", "line_type": "solid"},
            "apm_query": {
              "index": "trace-search",
              "search": {"query": "env:$env @organizationId:$organizationId name:hql.controller.executeSql"},
              "compute": {"aggregation": "pc50"},
              "group_by": []
            }
          },
          {
            "display_type": "line",
            "style": {"palette": "warm", "line_type": "dashed"},
            "apm_query": {
              "index": "trace-search",
              "search": {"query": "env:$env @organizationId:$organizationId name:hql.controller.executeSql"},
              "compute": {"aggregation": "pc95"},
              "group_by": []
            }
          },
          {
            "display_type": "line",
            "style": {"palette": "orange", "line_type": "dotted"},
            "apm_query": {
              "index": "trace-search",
              "search": {"query": "env:$env @organizationId:$organizationId name:hql.controller.executeSql"},
              "compute": {"aggregation": "pc99"},
              "group_by": []
            }
          }
        ]
      }
    },
    {
      "definition": {
        "type": "timeseries",
        "title": "HQL Error Count by Operation",
        "show_legend": true,
        "requests": [
          {
            "display_type": "bars",
            "style": {"palette": "warm"},
            "apm_query": {
              "index": "trace-search",
              "search": {"query": "env:$env @organizationId:$organizationId service:helicone-sql name:hql.controller.* status:error"},
              "compute": {"aggregation": "count"},
              "group_by": [{"facet": "name", "limit": 10}]
            }
          }
        ]
      }
    },
    {
      "definition": {
        "type": "note",
        "content": "## HQL Manager Operations\nDetailed metrics from manager-level traces",
        "background_color": "gray",
        "font_size": "14",
        "text_align": "center",
        "show_tick": false
      }
    },
    {
      "definition": {
        "type": "query_value",
        "title": "Average Query Result Size",
        "precision": 2,
        "requests": [
          {
            "apm_query": {
              "index": "trace-search",
              "search": {"query": "env:$env @organizationId:$organizationId name:hql.executeSql @result.size_bytes:>0"},
              "compute": {"aggregation": "avg"},
              "group_by": []
            }
          }
        ]
      }
    },
    {
      "definition": {
        "type": "query_value",
        "title": "Average Rows Returned",
        "precision": 0,
        "requests": [
          {
            "apm_query": {
              "index": "trace-search",
              "search": {"query": "env:$env @organizationId:$organizationId name:hql.executeSql @result.row_count:>0"},
              "compute": {"aggregation": "avg"},
              "group_by": []
            }
          }
        ]
      }
    },
    {
      "definition": {
        "type": "query_value",
        "title": "Average Execution Time",
        "precision": 0,
        "requests": [
          {
            "apm_query": {
              "index": "trace-search",
              "search": {"query": "env:$env @organizationId:$organizationId name:hql.executeSql @result.elapsed_ms:>0"},
              "compute": {"aggregation": "avg"},
              "group_by": []
            }
          }
        ]
      }
    },
    {
      "definition": {
        "type": "timeseries",
        "title": "SQL Query Execution Time vs Result Size",
        "show_legend": true,
        "yaxis": {"include_zero": true, "scale": "linear"},
        "requests": [
          {
            "display_type": "line",
            "style": {"palette": "purple"},
            "apm_query": {
              "index": "trace-search",
              "search": {"query": "env:$env @organizationId:$organizationId name:hql.executeSql @result.elapsed_ms:>0"},
              "compute": {"aggregation": "avg"},
              "group_by": []
            }
          },
          {
            "display_type": "line",
            "style": {"palette": "green"},
            "on_right_yaxis": true,
            "apm_query": {
              "index": "trace-search",
              "search": {"query": "env:$env @organizationId:$organizationId name:hql.executeSql @result.size_bytes:>0"},
              "compute": {"aggregation": "avg"},
              "group_by": []
            }
          }
        ]
      }
    },
    {
      "definition": {
        "type": "toplist",
        "title": "Top Error Types",
        "requests": [
          {
            "apm_query": {
              "index": "trace-search",
              "search": {"query": "env:$env @organizationId:$organizationId service:helicone-sql status:error @error.type:*"},
              "compute": {"aggregation": "count"},
              "group_by": [{"facet": "@error.type", "limit": 10}]
            }
          }
        ]
      }
    },
    {
      "definition": {
        "type": "toplist",
        "title": "Error Distribution by Phase",
        "requests": [
          {
            "apm_query": {
              "index": "trace-search",
              "search": {"query": "env:$env @organizationId:$organizationId service:helicone-sql status:error @error.phase:*"},
              "compute": {"aggregation": "count"},
              "group_by": [{"facet": "@error.phase", "limit": 10}]
            }
          }
        ]
      }
    },
    {
      "definition": {
        "type": "note",
        "content": "## CSV Download Performance",
        "background_color": "gray",
        "font_size": "14",
        "text_align": "center",
        "show_tick": false
      }
    },
    {
      "definition": {
        "type": "timeseries",
        "title": "CSV Download Operations",
        "show_legend": true,
        "requests": [
          {
            "display_type": "bars",
            "style": {"palette": "dog_classic"},
            "apm_query": {
              "index": "trace-search",
              "search": {"query": "env:$env @organizationId:$organizationId name:hql.downloadCsv"},
              "compute": {"aggregation": "count"},
              "group_by": []
            }
          },
          {
            "display_type": "line",
            "style": {"palette": "warm"},
            "on_right_yaxis": true,
            "apm_query": {
              "index": "trace-search",
              "search": {"query": "env:$env @organizationId:$organizationId name:hql.downloadCsv @csv.upload_time_ms:>0"},
              "compute": {"aggregation": "avg"},
              "group_by": []
            }
          }
        ]
      }
    },
    {
      "definition": {
        "type": "timeseries",
        "title": "CSV Export Row Counts",
        "show_legend": false,
        "requests": [
          {
            "display_type": "area",
            "style": {"palette": "cool"},
            "apm_query": {
              "index": "trace-search",
              "search": {"query": "env:$env @organizationId:$organizationId name:hql.downloadCsv @csv.row_count:>0"},
              "compute": {"aggregation": "max"},
              "group_by": []
            }
          }
        ]
      }
    },
    {
      "definition": {
        "type": "note",
        "content": "## Schema Operations",
        "background_color": "gray",
        "font_size": "14",
        "text_align": "center",
        "show_tick": false
      }
    },
    {
      "definition": {
        "type": "timeseries",
        "title": "Schema Fetch Performance",
        "show_legend": true,
        "requests": [
          {
            "display_type": "bars",
            "style": {"palette": "dog_classic"},
            "apm_query": {
              "index": "trace-search",
              "search": {"query": "env:$env @organizationId:$organizationId name:hql.getClickHouseSchema"},
              "compute": {"aggregation": "count"},
              "group_by": []
            }
          },
          {
            "display_type": "line",
            "style": {"palette": "purple"},
            "on_right_yaxis": true,
            "apm_query": {
              "index": "trace-search",
              "search": {"query": "env:$env @organizationId:$organizationId name:hql.getClickHouseSchema"},
              "compute": {"aggregation": "avg"},
              "group_by": []
            }
          }
        ]
      }
    },
    {
      "definition": {
        "type": "query_value",
        "title": "Total Schema Columns",
        "precision": 0,
        "requests": [
          {
            "apm_query": {
              "index": "trace-search",
              "search": {"query": "env:$env @organizationId:$organizationId name:hql.getClickHouseSchema @schema.total_columns:>0"},
              "compute": {"aggregation": "max"},
              "group_by": []
            }
          }
        ]
      }
    },
    {
      "definition": {
        "type": "note",
        "content": "## Query Performance Analysis",
        "background_color": "gray",
        "font_size": "14",
        "text_align": "center",
        "show_tick": false
      }
    },
    {
      "definition": {
        "type": "heatmap",
        "title": "Query Latency Heatmap",
        "requests": [
          {
            "apm_query": {
              "index": "trace-search",
              "search": {"query": "env:$env @organizationId:$organizationId name:hql.executeSql"},
              "compute": {"aggregation": "count"},
              "group_by": []
            }
          }
        ]
      }
    },
    
    {
      "definition": {
        "type": "toplist",
        "title": "Slowest Operations (p95 latency)",
        "requests": [
          {
            "apm_query": {
              "index": "trace-search",
              "search": {"query": "env:$env @organizationId:$organizationId service:helicone-sql name:hql.*"},
              "compute": {"aggregation": "pc95"},
              "group_by": [{"facet": "name", "limit": 10}]
            }
          }
        ]
      }
    },
    {
      "definition": {
        "type": "query_table",
        "title": "HQL Operation Summary",
        "requests": [
          {
            "apm_stats_query": {
              "env": "$env",
              "primary_tag": "env",
              "service": "helicone-sql",
              "name": "hql.*",
              "resource": "*",
              "row_type": "resource",
              "columns": [
                {"name": "Resource", "alias": "operation"},
                {"name": "Hits", "cell_display_mode": "bar"},
                {"name": "Errors", "cell_display_mode": "bar"},
                {"name": "Error %", "cell_display_mode": "number"},
                {"name": "Avg duration", "cell_display_mode": "number"},
                {"name": "p95 latency", "cell_display_mode": "number"}
              ]
            }
          }
        ]
      }
    },
    {
      "definition": {
        "type": "timeseries",
        "title": "S3 Enrichment Performance",
        "show_legend": true,
        "requests": [
          {
            "display_type": "line",
            "style": {"palette": "green"},
            "apm_query": {
              "index": "trace-search",
              "search": {"query": "env:$env @organizationId:$organizationId name:hql.executeSql @enrichment.elapsed_ms:>10"},
              "compute": {"aggregation": "avg"},
              "group_by": []
            }
          }
        ]
      }
    }
  ]
}
JSON
}