# PŘÍPRAVA — co udělat ty (Lukáš)

Tohle je návod pro tebe. Psaný tak, abys nemusel ničemu z oboru rozumět.
Agent (Claude) má svoje pravidla v `CLAUDE.md`. Ty máš tenhle soubor.

---

## 1. Jak to celé funguje (v 5 větách)

1. Repo na GitHubu obsahuje **plán** (milníky), **pravidla** pro agenta a **testy**.
2. Každou noc před školním dnem (~00:30) se na GitHubu v cloudu spustí počítač (**GitHub Actions**), na kterém pracuje Claude.
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
| **Claude Desktop** (záložka Code) | ✅ | potřeba jen jednou, na vygenerování tokenu |
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

### Krok 2 — Propojit Claude s repem (přes Claude Desktop)
**2a. Nainstaluj Claude GitHub App** (v prohlížeči)
- Otevři https://github.com/apps/claude → **Install** → *Only select repositories* → `blender-web` → Install.

**2b. Vygeneruj token z tvého předplatného** (Claude Desktop → záložka **Code**)
- Nová session → prostředí **Local** → složka `blender-web`.
- Otevři terminál v session: tlačítko **Terminal** nahoře, nebo **Ctrl + `**.
- Napiš `claude setup-token` a potvrď v prohlížeči.
- Pokud terminál napíše, že `claude` nezná: napiš Claudovi do chatu
  *„nainstaluj mi Claude Code CLI přes npm“* a pak to zkus znovu.
- Terminál vypíše dlouhý token (začíná `sk-ant-oat…`). **Zkopíruj ho.**

> 🔒 Token je jako heslo k tvému Claude předplatnému. **Nevkládej ho do žádného chatu**
> (ani Claudovi), jen do GitHub secretu v dalším kroku.

**2c. Ulož token do repa**
- GitHub → repo → *Settings → Secrets and variables → Actions* → **New repository secret**
- Name: **`CLAUDE_CODE_OAUTH_TOKEN`** (přesně takhle)
- Secret: vlož token → **Add secret**.

*(Alternativa: do promptu v Claude Desktop napsat `/install-github-app`. Potřebuje ale
nainstalované GitHub CLI a na konci vytvoří vlastní PR s `claude.yml` — ten PR pak **zavři,
nemerguj**, máme vlastní workflowy.)*

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
Pokud ano: hotovo, od teď to jede samo každou noc před školou. 🎉

---

## 4. Tvoje odpolední rutina (15–30 min)

> **Od 15. 10.:** agent běží **2× denně i o víkendu** (večer ~20:15, v noci ~00:30) a když
> testy projdou (`✅ CI`), **PR se mergne sám**. Ty řešíš jen PR, které zůstanou otevřené (`❌ CI`).
> Co se děje, vidíš v `STATUS.md` nebo v zavřených PR (Pull requests → Closed).

1. Otevři PR „Noc …“. **Popis PR = STATUS.md.**
2. Přečti **první řádek** (✅ / 🟡 / 🔴) a sekci **„Potřebuju od tebe“**.
3. **Úplně nahoře v popisu PR** je výsledek testů: `✅ CI` nebo `❌ CI`.
4. Když agent vyrobil obrázky (od M8), stáhni je: *Actions → běh → Artifacts*.
5. Rozhodni:
   - ✅ zelené + dává to smysl → **Merge** (Squash and merge).
   - 🟡 drobnost → komentář `@claude oprav …` a počkej.
   - 🔴 špatný směr → komentář s tím, co chceš jinak, **nemerguj**, PR zavři.

### Pravidla pro tebe (důležité)
- **Nikdy nemerguj PR s `❌ CI`.**
- **Nikdy nemerguj PR**, kde agent mění referenční obrázky, toleranci testů nebo
  `CLAUDE.md`, pokud to sám nevysvětlil a ty s tím nesouhlasíš.
- **3 noci po sobě 🔴 na stejné věci** → zastav to (Actions → Agent run → ⋯ → Disable)
  a napiš mi/Claudovi v chatu, ať to rozebereme.

---

### Ruční spuštění a volba modelu
*Actions → Agent run → Run workflow* má tři volby:
- `minutes` — kolik času agent dostane (max 270).
- `model` — **sonnet** (výchozí, rychlý, šetří limity) nebo **opus** (chytřejší, rychleji bere limity).
- `effort` — **medium** (běžně) nebo **high** (těžké problémy).

Noční běhy jedou vždy na sonnet/medium. **Opus + high** pouštěj ručně, když agent u stejného
problému stojí 2–3 noci, nebo u těžkých milníků (M8–M10: WebGPU backend a shadery).
Nejlépe večer po 20:00 (mimo špičku) a nejdřív **mergni poslední PR**, ať agent začne z aktuálního stavu.

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
| Workflow spadne hned na kroku Claude | chybí / špatný secret, nebo není nainstalovaná GitHub App | Krok 2 znovu |
| „Resource not accessible by integration“ | Actions nesmí psát | Krok 3 |
| Chyba typu „unexpected input“ u Claude kroku | změnil se formát oficiální action | otevři README `anthropics/claude-code-action` a uprav vstupy (nebo se zeptej Clauda v chatu) |
| PR se nevytvořil | nic se nezměnilo, nebo chybí oprávnění PR | Krok 3, podívej se do logu běhu |
| „No space left on device“ | plný disk runneru | napiš `@claude` ať zmenší build (vypnout další moduly) |
| Agent skončil po pár minutách | došel limit Pro | počkej, další běh pokračuje |
