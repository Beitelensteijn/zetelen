"use client";
// Hoofdmenu; markeert de huidige pagina (aria-current)
import Link from "next/link";
import { usePathname } from "next/navigation";
import { Woordmerk } from "./Typografie";
import s from "./kader.module.css";

// Alleen pagina's die bestaan; Verkenner, Fracties, Lezingen en Methodiek komen met hun component
const MENU = [{ href: "/over", tekst: "Over" }];

export function Navigatie() {
  const pad = usePathname();
  return (
    <header>
      <a href="#inhoud" className={s.overslaan}>
        Naar de inhoud
      </a>
      <nav className={s.nav} aria-label="Hoofdmenu">
        <Woordmerk />
        <ul className={s.links}>
          {MENU.map((m) => (
            <li key={m.href}>
              <Link href={m.href} aria-current={pad === m.href ? "page" : undefined}>
                {m.tekst}
              </Link>
            </li>
          ))}
        </ul>
      </nav>
    </header>
  );
}
