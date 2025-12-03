from pathlib import Path
import argparse
import re
from typing import Dict, List

import pandas as pd
import matplotlib.pyplot as plt

"""
Mapping from Id to nicer labels.
Can edit manually once we've completed our benchmarking runs
Format looks like: "20251123-000711": "Baseline"
"""
RUN_LABELS: Dict[str, str] = {

}

def parse_filename(stem: str):
    # Pases filename like 1-Insert into trial_id, run_id
    # We will use the stem as the run_id, and a default trial_id
    trial_id = "t1"
    run_id = stem
    return trial_id, run_id

def parse_ycsb_log(path: Path, db_name: str):
    trial_id, run_id = parse_filename(path.stem)

    rows: List[Dict] = []
    line_no = 0

    metric_line_pattern = re.compile(r'^\[(.+?)\]\s*,\s*([^,]+)\s*,\s*(.+)$') # Will need to test this regex online to make sure it works
    
    with path.open('r', encoding='utf-8', errors='ignore') as f:
        for raw_line in f:
            line_no += 1
            line = raw_line.strip()
            if not line.startswith('['):
                continue

            m = metric_line_pattern.match(line)
            if not m:
                continue

            section = m.group(1).strip()
            metric = m.group(2).strip()
            value_str = m.group(3).strip()

            try:
                # Remove commas from the value string
                value = float(value_str.replace(",", ""))
            except ValueError:
                value = value_str

            rows.append(
                {
                    "db": db_name,
                    "run_id": run_id,
                    "trial": trial_id,
                    "section": section,
                    "metric": metric,
                    "value": value,
                    "line_no": line_no,
                    "log_path": str(path),
                }
            )
    return rows

def collect_metrics(logs_dir: Path) -> pd.DataFrame:
    all_rows: List[Dict] = []

    if not logs_dir.exists():
        raise FileNotFoundError(f"Directory not found: {logs_dir}")

    for db_dir in logs_dir.iterdir():
        # Skip non-directories or folders that should be ignored
        if not db_dir.is_dir():
            continue
        IGNORED_DIRS = {"screenshots", "figures", ".git", "__pycache__"}
        if db_dir.name.lower() in IGNORED_DIRS:
            continue

        db_name = db_dir.name

        # Only parse .md files
        for log_path in db_dir.glob("*.md"):
            rows = parse_ycsb_log(log_path, db_name)
            all_rows.extend(rows)

    if not all_rows:
        raise RuntimeError(f"No metrics found under {logs_dir}")

    df = pd.DataFrame(all_rows)
    return df

def get_last_overall(df: pd.DataFrame) -> pd.DataFrame:
    overall = df[df["section"] == "OVERALL"].copy()
    if overall.empty:
        raise RuntimeError
    
    overall_sorted = overall.sort_values(["db", "run_id", "trial", "metric", "line_no"])
    # Take the last occurrence (largest line_no) per db+run_id+trial+metric
    last_overall = overall_sorted.groupby(
        ["db", "run_id", "trial", "metric"]
    ).tail(1)

    return last_overall

def average(last_overall: pd.DataFrame) -> pd.DataFrame:
    numeric = last_overall[pd.to_numeric(last_overall["value"], errors="coerce").notna()].copy()
    numeric["value"] = numeric["value"].astype(float)

    grouped = (
        numeric.groupby(["db", "run_id", "metric"])["value"]
        .mean()
        .reset_index()
        .rename(columns={"value": "avg_value"})
    )

    return grouped

def run_label(run_id: str) -> str:
    return RUN_LABELS.get(run_id, run_id)

def plot_grouped_bar(agg: pd.DataFrame, metric_name: str, ylabel: str, out_path: Path):
    subset = agg[agg["metric"] == metric_name]
    if subset.empty:
        print(f"No metrics found for {metric_name}; skipping plot.")
        return

    # Pivot to shape: index=run_id, columns=db, values=avg_value
    pivot = subset.pivot_table(
        index="run_id", columns="db", values="avg_value", aggfunc="mean"
    ).sort_index()

    # Prepare figure
    fig, ax = plt.subplots(figsize=(8, 4))

    x = range(len(pivot.index))
    width = 0.8 / max(len(pivot.columns), 1)  # total bar width per group

    # For each database, plot offset bars
    for i, db in enumerate(pivot.columns):
        offsets = [xi + (i - len(pivot.columns) / 2) * width + width / 2 for xi in x]
        ax.bar(offsets, pivot[db], width=width, label=db)

        # Add labels on top of bars
        for xi, val in zip(offsets, pivot[db]):
            ax.text(xi, val, f"{val:.1f}", ha="center", va="bottom", fontsize=8)

    ax.set_xticks(list(x))
    # Map run_id -> label if RUN_LABELS is populated
    labels = [run_label(rid) for rid in pivot.index]
    ax.set_xticklabels(labels, rotation=45, ha="right")

    ax.set_ylabel(ylabel)
    ax.set_title(f"{metric_name} by database and run")
    ax.legend()

    fig.tight_layout()
    fig.savefig(out_path, dpi=150)
    plt.close(fig)
    print(f"Saved {out_path}")

def main():
    parser = argparse.ArgumentParser(
        description="Parse YCSB logs, average trials, and generate comparison plots."
    )
    parser.add_argument(
        "--logs-dir",
        type=str,
        default="results",
        help="Path to the logs directory (default: logs)",
    )
    parser.add_argument(
        "--out-dir",
        type=str,
        default="figures",
        help="Directory to write output plots (default: figures)",
    )

    args = parser.parse_args()

    logs_dir = Path(args.logs_dir)
    out_dir = Path(args.out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    df = collect_metrics(logs_dir)

    # 1) Take only the final OVERALL metrics per (db, run_id, trial, metric)
    last_overall = get_last_overall(df)

    # 2) Average across trials for each (db, run_id, metric)
    avg_metrics = average(last_overall)

    # 3) Plot specific metrics
    plot_grouped_bar(
        avg_metrics,
        metric_name="Throughput(ops/sec)",
        ylabel="Throughput (ops/sec)",
        out_path=out_dir / "overall_throughput_by_db_and_run.png",
    )

    plot_grouped_bar(
        avg_metrics,
        metric_name="RunTime(ms)",
        ylabel="RunTime (ms)",
        out_path=out_dir / "overall_runtime_by_db_and_run.png",
    )

    print("Done.")


if __name__ == "__main__":
    main()
