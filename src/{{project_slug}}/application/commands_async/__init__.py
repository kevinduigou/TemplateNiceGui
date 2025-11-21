"""Async commands for long-running state-changing operations.

Commands in this module are executed by RQ workers and should be used for
operations that take a long time to complete, such as:
- Data imports/exports
- Batch processing
- External API calls with long response times
- Heavy computations

Each command should be a standalone function that can be enqueued and
executed by the RQ worker.
"""
