"use client";

import { motion } from "motion/react";
import { EASE, Eyebrow, Foot, R, type Slide } from "@slides/deck";
import type { Table, Topic } from "./topics/types";

function Rich({ text }: { text: string }) {
  return <>{text.split("**").map((part, k) => (k % 2 ? <strong key={k}>{part}</strong> : part))}</>;
}

function Grid({ table }: { table: Table }) {
  const { bands, cols, rows } = table;
  return (
    <div
      className="cmp"
      data-n={cols.length}
      style={{ gridTemplateColumns: `var(--label-w) repeat(${cols.length}, minmax(0, 1fr))`, gridTemplateRows: `auto auto repeat(${rows.length}, 1fr)` }}
    >
      <div className="cmp-corner" />
      {bands.map((b, k) => (
        <R key={b.name} i={1 + k} className={`cmp-band band-${k % 2}`} style={{ gridColumn: `span ${b.span}` }}>
          {b.name} {b.sub && <em>({b.sub})</em>}
        </R>
      ))}
      <div className="cmp-head cmp-label">Característica</div>
      {cols.map((g, c) => (
        <R key={g.name} i={2 + c} className="cmp-head">
          <img src={g.img.src} alt={g.name} />
          <span>
            <b>{g.name}</b>
            <small>{g.example}</small>
          </span>
        </R>
      ))}
      {rows.map((row, r) => (
        <motion.div
          key={row.label}
          className="cmp-row"
          initial={{ opacity: 0, y: 14 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, ease: EASE, delay: 0.45 + r * 0.06 }}
        >
          <div className="cmp-label">{row.label}</div>
          {row.cells.map(([text, span], k) => (
            <div key={k} className={span > 1 ? "cmp-cell shared" : "cmp-cell"} style={{ gridColumn: `span ${span}` }}>
              <span>
                <Rich text={text} />
              </span>
            </div>
          ))}
        </motion.div>
      ))}
    </div>
  );
}

export function topicSlides(topic: Topic): Slide[] {
  return topic.tables.map((table) => ({
    id: table.id,
    className: `cmp-slide${table.tone ? ` tone-${table.tone}` : ""}`,
    notes: table.notes,
    render: () => (
      <>
        <div className="cmp-top">
          <Eyebrow>Cuadro comparativo · {topic.name}</Eyebrow>
          <R i={1} as="h2" className="cmp-title">{table.title}</R>
        </div>
        <Grid table={table} />
        <Foot left={table.foot ?? "Celdas unidas: rasgo compartido"} right={`Diversidad Vegetal · ${topic.clase}`} />
      </>
    ),
  }));
}
