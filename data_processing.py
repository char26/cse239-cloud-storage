from pathlib import Path
import argparse
import re
import pandas as pd
import matplotlib.pyplot as plt

BLOCK_SPLIT = re.compile(r"```")

METRIC_PATTERN = re.compile(r'^\[(.+?)\]\s*,\s*([^,]+)\s*,\s*(.+)$')
TARGET_OPS_RE = re.compile(r'^##\s*Target\s+Ops/Sec\s*=\s*([0-9]+)')

LATENCY_METRICS = {
    "MinLatency(us)",
    "MaxLatency(us)",
    "AverageLatency(us)",
    "95thPercentileLatency(us)",
    "99thPercentileLatency(us)",
}

def parse_blocks(path: Path):
    text = path.read_text(errors="ignore")
    blocks = BLOCK_SPLIT.split(text)
    return [b for b in blocks if "[OVERALL]" in b]

def parse_block(block: str, db: str, run: str, idx: int, target_ops: float | None):
    rows = []
    for line in block.splitlines():
        line = line.strip()
        if not line.startswith("["):
            continue
        m = METRIC_PATTERN.match(line)
        if not m:
            continue

        section = m.group(1).strip()
        metric = m.group(2).strip()
        value = float(m.group(3).replace(",", ""))

        # 🚫 Ignore CLEANUP section entirely
        if section == "CLEANUP":
            continue

        rows.append({
            "db": db,
            "run": run,
            "step": idx,
            "target_ops": target_ops,
            "section": section,
            "metric": metric,
            "value": value,
        })
    return rows

def parse_file_with_targets(path: Path, db: str):
    """
    Parse a markdown file that can contain:
      - optional headings like: '## Target Ops/Sec = 200'
      - one or more fenced code blocks (``` ... ```)

    Each code block becomes a 'step', and is associated with the most recent
    Target Ops/Sec heading (if any).
    """
    rows = []
    text = path.read_text(errors="ignore")
    in_block = False
    block_lines: list[str] = []
    step_idx = 0
    current_target_ops: float | None = None

    for raw_line in text.splitlines():
        line = raw_line.rstrip("\n")

        # Look for "## Target Ops/Sec = X"
        m = TARGET_OPS_RE.match(line.strip())
        if m:
            current_target_ops = float(m.group(1))
            continue

        # Fence start/end
        if line.strip().startswith("```"):
            if not in_block:
                # starting a block
                in_block = True
                block_lines = []
            else:
                # ending a block -> parse the collected block
                block_text = "\n".join(block_lines)
                rows.extend(
                    parse_block(
                        block_text,
                        db=db,
                        run=path.stem,
                        idx=step_idx,
                        target_ops=current_target_ops,
                    )
                )
                step_idx += 1
                in_block = False
            continue

        if in_block:
            block_lines.append(line)

    return rows

def collect_all(results_dir: Path):
    rows = []
    for db_dir in results_dir.iterdir():
        if not db_dir.is_dir() or db_dir.name in {"screenshots", "figures"}:
            continue
        db = db_dir.name
        for md in db_dir.glob("*.md"):
            rows.extend(parse_file_with_targets(md, db))
    if not rows:
        raise RuntimeError(f"No metrics found under {results_dir}")
    return pd.DataFrame(rows)

def plot_load_throughput(df: pd.DataFrame, out: Path):
    # Only consider runs that look like Load tests
    load = df[df["run"].str.contains("Load", case=False, na=False)]

    for db in load["db"].unique():
        sub = load[
            (load["db"] == db)
            & (load["section"] == "OVERALL")
            & (load["metric"] == "Throughput(ops/sec)")
        ].copy()

        if sub.empty:
            continue

        # If target_ops is present, use it for the x-axis; otherwise fall back to step
        if "target_ops" in sub.columns and sub["target_ops"].notna().any():
            sub = sub.sort_values("target_ops")
            x = sub["target_ops"]
            xlabel = "Target Throughput (ops/sec)"
        else:
            sub = sub.sort_values("step")
            x = sub["step"]
            xlabel = "Load Step"

        y = sub["value"]

        fig, ax = plt.subplots()
        ax.plot(x, y, marker="o")

        # Label each point with achieved throughput
        for xi, yi in zip(x, y):
            ax.text(xi, yi, f"{yi:.0f}", ha="center", va="bottom", fontsize=8)

        ax.set_xlabel(xlabel)
        ax.set_ylabel("Achieved Throughput (ops/sec)")
        title_suffix = "vs Target" if "target_ops" in sub.columns else "Over Time"
        ax.set_title(f"{db} Load Throughput {title_suffix}")

        fig.tight_layout()
        fig.savefig(out / f"load_throughput_{db}.png", dpi=150)
        plt.close(fig)

def plot_soak_comparison(df, out):
    soak = df[df["run"].str.contains("Soak")]
    last = soak[soak["section"] == "OVERALL"].groupby("db").tail(1)
    vals = last[last["metric"] == "Throughput(ops/sec)"]
    plt.figure()
    plt.bar(vals["db"], vals["value"])
    plt.ylabel("Throughput (ops/sec)")
    plt.title("Soak Test Throughput Comparison")
    plt.savefig(out / "soak_throughput_comparison.png", dpi=150)
    plt.close()

def plot_latency(df: pd.DataFrame, out: Path):
    # Only latency-related metrics
    lat = df[df["metric"].isin(LATENCY_METRICS)].copy()

    # Split into load vs non-load based on filename
    load_mask = lat["run"].str.contains("Load", case=False, na=False)
    load_lat = lat[load_mask]
    nonload_lat = lat[~load_mask].copy()

    # ---------- 1) LOAD: per (db, run, section), x-axis = target_ops or step ----------
    for (db, run, section), group in load_lat.groupby(["db", "run", "section"]):
        if group.empty:
            continue

        # Prefer target_ops for x-axis; fall back to step
        if "target_ops" in group.columns and group["target_ops"].notna().any():
            group = group.sort_values("target_ops")
            x = group["target_ops"]
            xlabel = "Target Throughput (ops/sec)"
            suffix = "vs_target"
        else:
            group = group.sort_values("step")
            x = group["step"]
            xlabel = "Test Step"
            suffix = "by_step"

        fig, ax = plt.subplots()

        for metric in sorted(LATENCY_METRICS):
            g = group[group["metric"] == metric]
            if g.empty:
                continue
            ax.plot(
                x.loc[g.index],
                g["value"],
                marker="o",                 # markers so few points are visible
                label=metric,
            )

        ax.set_xlabel(xlabel)
        ax.set_ylabel("Latency (µs)")
        ax.set_title(f"{db} {run} {section} Latency Breakdown")
        ax.set_yscale("log")
        ax.legend()
        fig.tight_layout()


        safe_run = run.replace(" ", "_")
        safe_section = section.replace(" ", "_")
        fig.savefig(out / f"latency_{db}_{safe_run}_{safe_section}_{suffix}.png", dpi=150)
        plt.close(fig)

    # ---------- 2) INSERT/STRESS/SOAK: combined per (db, section) ----------
    # Derive a nicer label from the filename: "1-Insert" -> "Insert"
    nonload_lat["run_label"] = nonload_lat["run"].apply(
        lambda r: r.split("-", 1)[1] if "-" in r else r
    )

    priority = ["Insert", "Stress", "Soak"]

    for (db, section), group in nonload_lat.groupby(["db", "section"]):
        if group.empty:
            continue

        # Order x-axis as Insert, Stress, Soak (if present), then anything else
        labels = group["run_label"].unique()
        run_order = sorted(
            labels,
            key=lambda x: (priority.index(x) if x in priority else len(priority), x),
        )

        x_pos = list(range(len(run_order)))

        fig, ax = plt.subplots()

        for metric in sorted(LATENCY_METRICS):
            metric_rows = group[group["metric"] == metric]
            if metric_rows.empty:
                continue

            # One value per run_label (usually exactly one)
            by_run = metric_rows.groupby("run_label")["value"].mean()
            y_vals = [by_run.get(lbl, float("nan")) for lbl in run_order]

            ax.plot(
                x_pos,
                y_vals,
                marker="o",
                label=metric,
            )

        ax.set_xticks(x_pos)
        ax.set_xticklabels(run_order)
        ax.set_xlabel("Test Type")
        ax.set_ylabel("Latency (µs)")
        ax.set_title(f"{db} {section} Latency: Insert vs Stress vs Soak")
        ax.legend()
        fig.tight_layout()

        safe_section = section.replace(" ", "_")
        fig.savefig(out / f"latency_{db}_{safe_section}_combined_nonload.png", dpi=150)
        plt.close(fig)

def debug_dump(df: pd.DataFrame):
    print("\n================== PARSED DATA DUMP ==================\n")

    for (db, run), group in df.groupby(["db", "run"]):
        print(f"\n--- FILE: {run}.md | DB: {db} ---")

        for step, step_group in group.groupby("step"):
            target_ops = step_group["target_ops"].iloc[0]
            print(f"\n  >>> STEP {step} | Target Ops: {target_ops}")

            for section, sec_group in step_group.groupby("section"):
                print(f"    [{section}]")
                for _, row in sec_group.iterrows():
                    print(f"      {row['metric']} = {row['value']}")

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--logs-dir", default="results")
    parser.add_argument("--out-dir", default="figures")
    parser.add_argument("--debug", action="store_true", help="Print parsed data instead of plotting")
    args = parser.parse_args()

    logs = Path(args.logs_dir)
    out = Path(args.out_dir)
    out.mkdir(exist_ok=True)

    df = collect_all(logs)

    # Hard kill CLEANUP just in case
    df = df[df["section"] != "CLEANUP"]

    if args.debug:
        debug_dump(df)
        print("\n✅ Debug mode complete — no plots generated.\n")
        return

    plot_load_throughput(df, out)
    plot_soak_comparison(df, out)
    plot_latency(df, out)

    print("✅ Load, Soak, and Latency graphs generated successfully.")

if __name__ == "__main__":
    main()
