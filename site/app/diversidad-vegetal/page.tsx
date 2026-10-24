import Link from "next/link";
import { topics } from "@slides/diversidad-vegetal";

export default function Home() {
  return (
    <main className="index">
      <p className="eyebrow">
        <i />
        Diversidad Vegetal · UNMSM
      </p>
      <h1>Cuadros comparativos</h1>
      <ul>
        {topics.map((t) => (
          <li key={t.slug} className={`theme-${t.slug}`}>
            <Link href={`/diversidad-vegetal/${t.slug}/`}>
              <small>{t.clase}</small>
              <b>{t.name}</b>
              <span>{t.summary}</span>
            </Link>
          </li>
        ))}
      </ul>
    </main>
  );
}
