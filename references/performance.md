# Speed and data

- Measure runtime with a profiler before and after every optimization, optimize only measured bottlenecks, and report before/after numbers.
- Pick the right data structure for each task (e.g. a set/dict for membership checks instead of a list).
- Prefer bulk over per-item operations (e.g. NumPy/pandas column operations instead of row loops; one SQL query instead of many).
- Cache expensive results (e.g. `functools.lru_cache`) and read files only once.
- Load only the data actually needed (required columns/rows) and use compact data types.
- Choose a storage format that fits the purpose (e.g. Parquet for large tables, CSV only when the file must open in Excel).
- Process large data in chunks or via generators/streams so it never sits in memory all at once.
