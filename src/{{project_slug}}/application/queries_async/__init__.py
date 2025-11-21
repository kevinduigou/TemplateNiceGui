"""Async queries for long-running read operations.

Queries in this module are executed by RQ workers and should be used for
read operations that take a long time to complete, such as:
- Complex data aggregations
- Report generation
- Large data exports
- External API queries with long response times

Each query should be a standalone function that can be enqueued and
executed by the RQ worker.
"""
