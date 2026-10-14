# PŘÍPRAVA — co udělat ty (Lukáš)

Tohle je návod pro tebe. Psaný tak, abys nemusel ničemu z oboru rozumět.
Agent (Claude) má svoje pravidla v `CLAUDE.md`. Ty máš tenhle soubor.

---

## 1. Jak to celé funguje (v 5 větách)

1. Repo na GitHubu obsahuje **plán** (milníky), **pravidla** pro agenta a **testy**.
2. Každý všední den ráno (7:15) se na GitHubu v cloudu spustí počítač (**GitHub Actions**), na kterém pracuje Claude.
3. Claude dělá jeden malý krok aktuálního milníku, otestuje ho a zapíše, co udělal.
4. Ráno je na GitHubu **Pull Request (PR)** = „návrh změn“, který si přečteš.
5. Když je PR v pořádku, dáš **Merge** (= přijmout). Když ne, napíšeš komentář `@claude …`.

Nic se nebuilduje na tvém PC. Celé to běží v cloudu.

---

## 2. Co potřebuješ

| Co | Máš? | Poznámka |
|---|---|---|
| GitHub účet | ✅ (GGlukyy) | |
| Claude Pro | ✅ | noční běhy jedou z tvého předplatného |
| GitHub Desktop | ✅ | na nahrání souborů |
| **Claude Code** na PC | ✅ | potřeba jen jednou, na propojení s GitHubem |
| Node.js 22 | jen pokud chceš něco zkoušet lokálně | |

Nic dalšího (Emscripten, Blender ze zdrojáku…) instalovat **nemusíš**.

---

## 3. Jednorázové nastavení (~30–45 min)

### Krok 1 — Repo
1. Na GitHubu: **New repository** → název např. `blender-web` → **Public** → bez README.
   - *Proč Public:* Actions jsou pro veřejná repa zdarma. U privátního by ti došly minuty za pár nocí.
   - *Proč to nevadí:* Blender je open source (GPL), tvoje změny musí být stejně veřejné.
2. V GitHub Desktop: *File → Clone repository* → `blender-web`.
3. Zkopíruj **celý obsah** téhle složky do složky repa (včetně skryté složky `.github`!).
4. Commit „Startovní kostra“ → **Push**.

> ⚠️ Složka `.github` je skrytá. Ve Windows: Průzkumník → Zobrazit → Skryté položky.

### Krok 2 — Propojit Claude s repem
Otevři terminál ve složce repa a spusť Claude Code:
```
claude
```
V Claude Code napiš:
```
/install-github-app
```
a projdi průvodce. Nainstaluje Claude aplikaci do repa a vytvoří token.
**Na konci zkontroluj** na GitHubu: *Settings → Secrets and variables → Actions*,
že tam je secret **`CLAUDE_CODE_OAUTH_TOKEN`**.
Pokud se jmenuje jinak, ručně: v terminálu `claude setup-token` a výsledek ulož
jako nový secret s tímhle přesným jménem.

### Krok 3 — Povolit Actions psát a dělat PR
GitHub → repo → *Settings → Actions → General*:
- **Workflow permissions:** ✅ *Read and write permissions*
- ✅ *Allow GitHub Actions to create and approve pull requests*
- Ulož.

### Krok 4 — Až vyjde Blender 5.3
Otevři `versions.env` a zkontroluj tři věci:
- `BLENDER_TAG` — přesný název tagu (najdeš na projects.blender.org → blender → Tags).
- `DESKTOP_BLENDER_URL` — odkaz na Linux verzi z download.blender.org.
- `EMSDK_VERSION` — aktuální stabilní verze Emscriptenu (github.com/emscripten-core/emsdk → Releases).

Pak už je **neměň**. Celý projekt stojí na jedné verzi.

### Krok 5 — Zkušební běh (60 minut)
GitHub → **Actions** → *Agent run* → **Run workflow** → `minutes` = **60** → Run.
Za ~1,5 hodiny by měl být v záložce **Pull requests** první PR.
Pokud ano: hotovo, od teď to jede samo každý všední den, zatímco jsi ve škole. 🎉

---

## 4. Tvoje odpolední rutina (15–30 min)

1. Otevři PR „Noc …“. **Popis PR = STATUS.md.**
2. Přečti **první řádek** (✅ / 🟡 / 🔴) a sekci **„Potřebuju od tebe“**.
3. Podívej se dole na **checks**: je CI zelené? ✅
4. Když agent vyrobil obrázky (od M8), stáhni je: *Actions → běh → Artifacts*.
5. Rozhodni:
   - ✅ zelené + dává to smysl → **Merge** (Squash and merge).
   - 🟡 drobnost → komentář `@claude oprav …` a počkej.
   - 🔴 špatný směr → komentář s tím, co chceš jinak, **nemerguj**, PR zavři.

### Pravidla pro tebe (důležité)
- **Nikdy nemerguj červené CI.**
- **Nikdy nemerguj PR**, kde agent mění referenční obrázky, toleranci testů nebo
  `CLAUDE.md`, pokud to sám nevysvětlil a ty s tím nesouhlasíš.
- **3 noci po sobě 🔴 na stejné věci** → zastav to (Actions → Agent run → ⋯ → Disable)
  a napiš mi/Claudovi v chatu, ať to rozebereme.

---

## 5. Co realisticky čekat

- **První 1–2 týdny** = infrastruktura (M0–M4). Žádné obrázky, jen „build prošel“. To je normální.
- **M5 (Blender běží v Node)** = první „wow“. Odhad: několik týdnů.
- **M10 (kostka v prohlížeči)** = hlavní milník. Odhad: měsíce.
- Agent se **bude** zasekávat — hlavně u závislostí, Pythonu a shaderů. Proto `BLOCKED` v STATUS.md.
- Je možné, že některý milník nepůjde vůbec. I tak budeš mít zdokumentovaný postup, což je samo o sobě hodnotné.

### Limity
- **Claude Pro:** noční běh spotřebuje hodně. Když dojde limit, agent skončí dřív a PR obsahuje
  rozdělanou práci (nic se neztratí). Když ti limity chybí přes den, dej menší `minutes`
  nebo změň `cron` v `.github/workflows/nightly-agent.yml`.
- **GitHub runner:** max 6 hodin na běh, omezený disk a ~10 GB cache na repo.
  Když cache zmizí, další noc se Blender builduje znovu od nuly (pomalé, ale funguje).
- **Žádné GPU v cloudu:** WebGPU testy jedou přes softwarový renderer. Pomalé, ale stačí.

### Varianta B (později, pokud cloud nestačí)
Self-hosted runner = noční běhy na **tvém PC** (7800X3D, 32 GB, RTX 5070 Ti → rychlejší build,
skutečné GPU). Nevýhody: PC musí v noci běžet a repo by kvůli bezpečnosti mělo být **private**.
Řeš až když narazíš na limity.

---

## 6. Co se naučit (minimum, ~1–2 h týdně)

Nemusíš umět programovat backend. Potřebuješ **rozumět tomu, co čteš v PR**.

| Téma | Proč | Kde |
|---|---|---|
| Git: PR, merge, revert | abys uměl přijmout / vrátit změnu | GitHub Docs → „About pull requests“ |
| Co je build a CMake | v logu uvidíš „configure / build / link“ | developer.blender.org → Building Blender |
| WebAssembly a Emscripten | jak se C++ dostane do prohlížeče | emscripten.org → Tutorial |
| Shader + WebGPU | co je backend a proč se překládají shadery | webgpufundamentals.org (první 2–3 lekce) |
| Číst log chyby | najít první `error:` v logu | prostě dělat, agent ti to vždy vysvětlí |

Tip: když v PR něčemu nerozumíš, napiš do komentáře
`@claude vysvětli mi jednoduše, co tahle změna dělá`.

---

## 7. Slovníček

- **Repo** — složka projektu na GitHubu.
- **Commit** — uložený krok změn.
- **PR (Pull Request)** — návrh změn, který schvaluješ.
- **Merge** — přijmout PR do hlavní větve (`main`).
- **CI** — automatické testy, které běží u každého PR.
- **Actions** — GitHub počítače v cloudu, které spouští noční běh a CI.
- **Workflow** — recept pro Actions (soubory v `.github/workflows/`).
- **Secret** — tajná hodnota v repu (token), kterou nikdo nevidí.
- **Cache** — uložené výsledky buildu, aby se nemusely dělat znovu.
- **Wasm (WebAssembly)** — formát, ve kterém běží C++ kód v prohlížeči.
- **Emscripten** — překladač z C++ do wasm.
- **WebGPU** — moderní grafické rozhraní prohlížeče.
- **Backend** — „ovladač“, přes který Blender kreslí (Vulkan, Metal… a nově WebGPU).
- **Shader** — malý program běžící na grafické kartě.
- **Patch** — soubor se všemi našimi změnami Blenderu.
- **Milník / DoD** — cíl a test, který dokazuje, že je hotový.

---

## 8. Když něco nefunguje

| Příznak | Pravděpodobná příčina | Co udělat |
|---|---|---|
| Workflow spadne hned na kroku Claude | chybí / špatný secret | Krok 2 znovu |
| „Resource not accessible by integration“ | Actions nesmí psát | Krok 3 |
| Chyba typu „unexpected input“ u Claude kroku | změnil se formát oficiální action | otevři README `anthropics/claude-code-action` a uprav vstupy (nebo se zeptej Clauda v chatu) |
| PR se nevytvořil | nic se nezměnilo, nebo chybí oprávnění PR | Krok 3, podívej se do logu běhu |
| „No space left on device“ | plný disk runneru | napiš `@claude` ať zmenší build (vypnout další moduly) |
| Agent skončil po pár minutách | došel limit Pro | počkej, další běh pokračuje |
