// Tekstcomponenten van het ontwerpsysteem: koppen, lopende tekst, labels, datalabels en cijfers
import type { ReactNode } from "react";
import s from "./typografie.module.css";

export function HeroKop({ children }: { children: ReactNode }) {
  return <h1 className={s.hero}>{children}</h1>;
}

export function SectieKop({ children, id }: { children: ReactNode; id?: string }) {
  return (
    <h2 className={s.sectie} id={id}>
      {children}
    </h2>
  );
}

export function Tekst({ children }: { children: ReactNode }) {
  return <p className={s.tekst}>{children}</p>;
}

// Rubriekslabel: kleine kapitalen in koper
export function Label({ children }: { children: ReactNode }) {
  return <span className={s.label}>{children}</span>;
}

// Datalabel en bronvermelding in DM Mono
export function Data({ children }: { children: ReactNode }) {
  return <span className={s.data}>{children}</span>;
}

// Uitgelicht cijfer, bijvoorbeeld een cohesie in procenten
export function Cijfer({ children }: { children: ReactNode }) {
  return <span className={s.cijfer}>{children}</span>;
}

// Woordmerk: Zetelen in Newsreader, kleine kapitalen, zonder logo
export function Woordmerk() {
  return (
    <a href="/" className={s.woordmerk}>
      Zetelen
    </a>
  );
}
