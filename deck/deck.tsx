"use client";

import { AnimatePresence, motion } from "motion/react";
import { useCallback, useEffect, useState } from "react";
import { EASE } from "./motion";
import type { Slide } from "./ui";

const slideClass = (s: Slide) => ["slide", s.dark && "dark", s.className].filter(Boolean).join(" ");
const pageNumber = (index: number) => String(index + 1).padStart(2, "0");

// Printing lays out every slide as one page; see the print rules in styles.css.
function PrintPages({ slides }: { slides: Slide[] }) {
  return (
    <div className="print">
      {slides.map((s, k) => (
        <section key={s.id} className={slideClass(s)}>
          <div className="grain" />
          {s.render(pageNumber(k))}
        </section>
      ))}
    </div>
  );
}

export function Deck({ slides }: { slides: Slide[] }) {
  const [[index, dir], setState] = useState<[number, number]>([0, 1]);
  const [notes, setNotes] = useState(false);
  const [scale, setScale] = useState(1);

  const go = useCallback((next: number) => {
    setState(([cur]) => {
      const n = Math.max(0, Math.min(slides.length - 1, next));
      return n === cur ? [cur, 1] : [n, n > cur ? 1 : -1];
    });
  }, []);

  useEffect(() => {
    const fromHash = Number.parseInt(location.hash.slice(1), 10);
    if (fromHash > 0) setState([Math.min(slides.length, fromHash) - 1, 1]);
  }, []);

  useEffect(() => {
    history.replaceState(null, "", `#${index + 1}`);
  }, [index]);

  useEffect(() => {
    const fit = () => setScale(Math.min(innerWidth / 1600, innerHeight / 900) * 0.98);
    fit();
    addEventListener("resize", fit);
    return () => removeEventListener("resize", fit);
  }, []);

  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if (["ArrowRight", " ", "PageDown", "Enter"].includes(e.key)) go(index + 1);
      else if (["ArrowLeft", "PageUp", "Backspace"].includes(e.key)) go(index - 1);
      else if (e.key === "Home") go(0);
      else if (e.key === "End") go(slides.length - 1);
      else if (e.key.toLowerCase() === "n") setNotes((v) => !v);
      else if (e.key.toLowerCase() === "f") document.documentElement.requestFullscreen?.();
    };
    addEventListener("keydown", onKey);
    return () => removeEventListener("keydown", onKey);
  }, [go, index]);

  const slide = slides[index];
  const next = slides[index + 1]?.speaker;
  const handoff = slide.speaker && next && next !== slide.speaker ? next : undefined;

  return (
    <>
      <div className="viewport" onClick={(e) => go(e.clientX > innerWidth / 2 ? index + 1 : index - 1)}>
        <div className="stage" style={{ transform: `translate(-50%, -50%) scale(${scale})` }}>
          <AnimatePresence initial={false} custom={dir} mode="popLayout">
            <motion.section
              key={slide.id}
              className={slideClass(slide)}
              custom={dir}
              variants={{
                enter: (d: number) => ({ opacity: 0, x: d * 60, filter: "blur(6px)" }),
                center: { opacity: 1, x: 0, filter: "blur(0px)" },
                exit: (d: number) => ({ opacity: 0, x: d * -60, filter: "blur(6px)" }),
              }}
              initial="enter"
              animate="center"
              exit="exit"
              transition={{ duration: 0.55, ease: EASE }}
            >
              <div className="grain" />
              {slide.render(pageNumber(index))}
            </motion.section>
          </AnimatePresence>
          <motion.div
            className="progress"
            animate={{ width: `${((index + 1) / slides.length) * 100}%` }}
            transition={{ duration: 0.6, ease: EASE }}
          />
        </div>
      </div>
      <div className="hud">
        {slide.speaker && <span className="speaker">{slide.speaker}{handoff && <b> → sigue {handoff}</b>}</span>}
        <span>{index + 1} / {slides.length}</span>
        <span>N notas · F pantalla completa</span>
        <button type="button" onClick={() => print()}>
          PDF
        </button>
      </div>
      <PrintPages slides={slides} />
      <AnimatePresence>
        {notes && (
          <motion.div
            className="notes"
            initial={{ y: "100%" }}
            animate={{ y: 0 }}
            exit={{ y: "100%" }}
            transition={{ duration: 0.4, ease: EASE }}
          >
            <small>Notas · {index + 1} / {slides.length}{slide.speaker && ` · ${slide.speaker}`}{handoff && ` → sigue ${handoff}`}</small>
            {slide.notes}
          </motion.div>
        )}
      </AnimatePresence>
    </>
  );
}
