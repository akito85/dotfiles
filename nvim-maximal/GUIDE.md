# Neovim Configuration Guide

> A comprehensive guide to mastering your Neovim setup, keybindings, and workflow optimization

## Table of Contents

1. [Configuration Overview](#configuration-overview)
2. [Essential Keybindings](#essential-keybindings)
3. [Plugin Reference](#plugin-reference)
4. [Vim Movement Fundamentals](#vim-movement-fundamentals)
5. [Advanced Movement Techniques](#advanced-movement-techniques)
6. [LSP Integration](#lsp-integration)
7. [Workflow Optimization](#workflow-optimization)
8. [Plugin Maximization Strategies](#plugin-maximization-strategies)

---

## Configuration Overview

### Architecture

```
nvim-maximal/
├── init.lua              # Entry point, bootstraps lazy.nvim
├── lua/
│   ├── core/
│   │   ├── init.lua      # Core module loader
│   │   ├── options.lua   # Vim options and settings
│   │   └── keymaps.lua   # Core keybindings
│   └── plugins/
│       └── init.lua      # All plugin configurations
└── lazy-lock.json        # Plugin version lock file
```

### Leader Key

- **Leader**: `Space`
- **Local Leader**: `Space`

Set before any mappings to ensure consistency.

### Core Philosophy

1. **Performance First**: Disabled unnecessary built-ins, optimized for large files
2. **Modern LSP**: Full IDE-like features with native LSP
3. **Vim Motions**: Enhanced but respects vim fundamentals
4. **Minimal Dependencies**: Only essential plugins

---

## Essential Keybindings

### Basic Navigation

| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `jk` | Insert | `<ESC>` | Fast escape (rolling motion) |
| `H` | Normal/Visual | `^` | Jump to line start |
| `L` | Normal/Visual | `$` | Jump to line end |
| `j` | Normal | `gj` | Move down (respects wrapped lines) |
| `k` | Normal | `gk` | Move up (respects wrapped lines) |
| `J` | Normal/Visual | `}` | Jump to next paragraph |
| `K` | Normal/Visual | `{` | Jump to previous paragraph |

### Enhanced Scrolling

| Key | Action | Description |
|-----|--------|-------------|
| `<C-d>` | Half-page down + center | Scroll down and center cursor |
| `<C-u>` | Half-page up + center | Scroll up and center cursor |
| `n` | Next search + center | Find next and center |
| `N` | Previous search + center | Find previous and center |

### Window Management

| Key | Action | Description |
|-----|--------|-------------|
| `<C-h>` | Move to left window | Navigate left (works in tmux too) |
| `<C-j>` | Move to window below | Navigate down (works in tmux too) |
| `<C-k>` | Move to window above | Navigate up (works in tmux too) |
| `<C-l>` | Move to right window | Navigate right (works in tmux too) |
| `<leader>v` | `:vsplit` | Vertical split |
| `<leader>s` | `:split` | Horizontal split |

**Note**: Window navigation works seamlessly with tmux panes via Navigator.nvim

### Buffer Management

| Key | Action | Description |
|-----|--------|-------------|
| `<leader>[` | Previous buffer | Navigate to previous buffer |
| `<leader>]` | Next buffer | Navigate to next buffer |
| `<leader>d` | Delete buffer | Close current buffer |
| `<leader>b` | Buffer manager | Open interactive buffer menu |

### File Operations

| Key | Action | Description |
|-----|--------|-------------|
| `<leader>w` | Save | Write current buffer |
| `<leader>q` | Quit | Close current window |
| `<leader>Q` | Force quit all | Emergency exit |

### Terminal

| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `<leader>t` | Normal | Open terminal | Quick terminal access |
| `<Esc>` | Terminal | Exit terminal mode | Return to normal mode |
| `jk` | Terminal | Exit terminal mode | Alternative escape |
| `<C-h/j/k/l>` | Terminal | Navigate away | Seamless window switching |

### Search & Replace

| Key | Action | Description |
|-----|--------|-------------|
| `<Esc>` | Clear search highlight | Remove search highlights |
| `<leader>ffr` | Find and replace | Open Far.vim (project-wide replace) |
| `<leader>ffd` | Execute replace | Apply Far.vim changes |

---

## Plugin Reference

### File Navigation & Fuzzy Finding

#### Telescope (`<leader>f` prefix)

| Key | Command | Purpose |
|-----|---------|---------|
| `<leader>ff` | Find files | Fuzzy find files in project |
| `<leader>fg` | Live grep | Search text across project |
| `<leader>fb` | Buffers | List and switch buffers |
| `<leader>fh` | Help tags | Search Neovim help |

**Power Tips**:
- In Telescope: `<C-n>/<C-p>` to navigate, `<C-j>/<C-k>` also works
- Use ripgrep patterns in live_grep (e.g., `function.*export`)
- `<C-q>` sends results to quickfix list

#### Neo-tree

| Key | Command | Purpose |
|-----|---------|---------|
| `<leader>e` | Toggle tree | Show/hide file explorer |

**In Neo-tree**:
- `a`: Add file/directory
- `d`: Delete
- `r`: Rename
- `c`: Copy
- `x`: Cut
- `p`: Paste
- `R`: Refresh
- `?`: Show help

#### Buffer Manager

| Key | Command | Purpose |
|-----|---------|---------|
| `<leader>b` | Toggle menu | Interactive buffer switching |

**In Buffer Manager**:
- Number keys (1-0): Quick jump to buffer
- `<C-v>`: Open in vertical split
- `<C-h>`: Open in horizontal split

### Motion Enhancement

#### Leap.nvim (Lightning-fast navigation)

| Key | Action | Description |
|-----|--------|-------------|
| `s{char}{char}` | Forward leap | Jump to visible location (2-char search) |
| `S{char}{char}` | Backward leap | Jump backward (2-char search) |

**Usage Pattern**:
1. Press `s`
2. Type 2 characters of target location
3. Select highlighted label if multiple matches

**Why it's powerful**: Navigate to any visible location in 2-4 keystrokes.

#### Quick-scope

Automatically highlights f/F/t/T targets:
- Press `f` and see unique characters highlighted
- Jump instantly to less common letters

#### Harpoon (Mark frequently used files)

| Key | Action | Description |
|-----|--------|-------------|
| `<leader>m` | Mark file | Add current file to Harpoon |
| `<leader>h` | Toggle menu | Show marked files |
| `<leader>1-4` | Jump to file 1-4 | Quick access to marked files |

**Workflow**:
1. Mark your 4 most-used files in a session
2. Jump between them instantly without fuzzy finding
3. Perfect for test file ↔ implementation switching

### LSP & Code Intelligence

#### LSP Navigation

| Key | Action | Description |
|-----|--------|-------------|
| `<leader>gd` | Go to definition | Jump to symbol definition |
| `<leader>gD` | Go to declaration | Jump to declaration |
| `<leader>gr` | Show references | List all references |
| `<leader>gi` | Go to implementation | Jump to implementation |
| `<leader>gt` | Go to type definition | Jump to type definition |
| `<leader>gh` | Hover documentation | Show documentation |
| `<leader>rn` | Rename symbol | Refactor rename |
| `<leader>ca` | Code actions | Show available code actions |

#### LSP Diagnostics

| Key | Action | Description |
|-----|--------|-------------|
| `[d` | Previous diagnostic | Jump to previous error/warning |
| `]d` | Next diagnostic | Jump to next error/warning |
| `<leader>e` | Show line diagnostics | Float diagnostics for current line |
| `<leader>q` | Location list | Add diagnostics to location list |
| `<leader>Q` | Quickfix list | Add diagnostics to quickfix |

#### Formatting & Utilities

| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `<leader>f` | Normal/Visual | Format | Format buffer or selection |
| `<leader>ih` | Normal | Toggle inlay hints | Show/hide type hints |
| `<C-h>` | Insert | Signature help | Show function signature |

### Completion (nvim-cmp)

| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `<C-Space>` | Insert | Trigger completion | Manual completion trigger |
| `<CR>` | Insert | Confirm | Accept completion |
| `<Tab>` | Insert | Next item | Navigate completion menu down |
| `<S-Tab>` | Insert | Previous item | Navigate completion menu up |

**Completion Sources** (in priority order):
1. LSP
2. LuaSnip snippets
3. Buffer words
4. File paths

### Language-Specific Features

#### Flutter (`<leader>F` prefix)

| Key | Action |
|-----|--------|
| `<leader>Fc` | Flutter commands |
| `<leader>Fr` | Reload |
| `<leader>FR` | Restart |
| `<leader>Fq` | Quit |
| `<leader>Fd` | Devices |
| `<leader>Fe` | Emulators |
| `<leader>Fo` | Outline toggle |
| `<leader>Ft` | DevTools |
| `<leader>Fl` | Clear logs |

#### Java (`<leader>J` prefix)

| Key | Action |
|-----|--------|
| `<leader>Jo` | Organize imports |
| `<leader>Jv` | Extract variable |
| `<leader>Jc` | Extract constant |
| `<leader>Jm` | Extract method (visual) |
| `<leader>Jt` | Test nearest method |
| `<leader>JT` | Test class |
| `<leader>Ju` | Update config |

### Treesitter Text Objects

| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `af` | Visual/Operator | Function outer | Select function with name/signature |
| `if` | Visual/Operator | Function inner | Select function body |
| `ac` | Visual/Operator | Class outer | Select entire class |
| `ic` | Visual/Operator | Class inner | Select class body |
| `aa` | Visual/Operator | Parameter outer | Select parameter |
| `ia` | Visual/Operator | Parameter inner | Select parameter value |

**Movement**:
- `]f` / `[f`: Next/previous function start
- `]c` / `[c`: Next/previous class start
- `]a` / `[a`: Next/previous parameter

**Swap**:
- `<leader>sp`: Swap parameter with next
- `<leader>sP`: Swap parameter with previous

**Example workflows**:
- `daf`: Delete entire function
- `vif`: Select function body
- `yac`: Yank entire class
- `]f`: Jump to next function
- `3]a`: Jump 3 parameters forward

### Productivity Tools

#### No Neck Pain

| Key | Action |
|-----|--------|
| `<leader>n` | Toggle centered mode |

Centers your buffer for focused writing/coding.

---

## Vim Movement Fundamentals

### The Vim Philosophy

Vim's power comes from **composability**: operators + motions.

```
[count] operator [count] motion
```

### Basic Motions

#### Character & Line
- `h` `j` `k` `l`: Left, down, up, right
- `0`: Start of line
- `^`: First non-blank character
- `$`: End of line
- `g_`: Last non-blank character

#### Words
- `w`: Next word start
- `W`: Next WORD start (whitespace-delimited)
- `e`: Next word end
- `E`: Next WORD end
- `b`: Previous word start
- `B`: Previous WORD start

**Word vs WORD**:
- `word`: Delimited by non-alphanumeric (e.g., `foo-bar` = 3 words)
- `WORD`: Delimited by whitespace (e.g., `foo-bar` = 1 WORD)

#### Paragraphs & Blocks
- `{`: Previous paragraph
- `}`: Next paragraph
- `(`: Previous sentence
- `)`: Next sentence
- `[[`: Previous section
- `]]`: Next section

#### Search-based
- `f{char}`: Find character forward (on line)
- `F{char}`: Find character backward
- `t{char}`: Till character forward (before char)
- `T{char}`: Till character backward
- `;`: Repeat last f/F/t/T
- `,`: Repeat in opposite direction
- `/pattern`: Search forward
- `?pattern`: Search backward
- `*`: Search for word under cursor
- `#`: Search backward for word under cursor

### Operators

| Operator | Action | Example |
|----------|--------|---------|
| `d` | Delete | `dw` = delete word |
| `c` | Change (delete + insert) | `ciw` = change inner word |
| `y` | Yank (copy) | `yap` = yank paragraph |
| `v` | Visual select | `vip` = select paragraph |
| `>` | Indent | `>ap` = indent paragraph |
| `<` | Unindent | `<ip` = unindent paragraph |
| `=` | Auto-indent | `=ap` = format paragraph |
| `g~` | Toggle case | `g~iw` = toggle word case |
| `gu` | Lowercase | `guiw` = lowercase word |
| `gU` | Uppercase | `gUiw` = uppercase word |

### Text Objects

#### Inner vs A (around)
- `i`: Inner (excludes delimiters)
- `a`: Around (includes delimiters)

| Object | Inner | Around | Example |
|--------|-------|--------|---------|
| `w` | Word | Word + space | `ciw` / `caw` |
| `W` | WORD | WORD + space | `ciW` / `caW` |
| `s` | Sentence | Sentence + space | `cis` / `cas` |
| `p` | Paragraph | Paragraph + blank line | `cip` / `cap` |
| `"` | Inside quotes | With quotes | `ci"` / `ca"` |
| `'` | Inside single quotes | With quotes | `ci'` / `ca'` |
| `` ` `` | Inside backticks | With backticks | ``ci` `` / ``ca` `` |
| `(` or `)` | Inside parens | With parens | `ci(` / `ca(` |
| `[` or `]` | Inside brackets | With brackets | `ci[` / `ca[` |
| `{` or `}` | Inside braces | With braces | `ci{` / `ca{` |
| `<` or `>` | Inside angle brackets | With brackets | `ci<` / `ca<` |
| `t` | Inside XML/HTML tag | With tags | `cit` / `cat` |

---

## Advanced Movement Techniques

### The 80/20 of Movement

**20% of commands that handle 80% of navigation:**

1. **`{` / `}`**: Navigate functions/blocks
2. **`Ctrl-d` / `Ctrl-u`**: Half-page jumps
3. **`s{char}{char}`**: Leap to visible location
4. **`/pattern<CR>`**: Long-range search
5. **`f{char}` + `;`**: Line-local navigation
6. **`*`**: Find word under cursor
7. **`<leader>gd`**: Go to definition
8. **`` `  ``** or `Ctrl-o`: Jump back

### Movement Patterns by Distance

#### Short Range (same line)
```
1. f{char}    - "find" to jump to character
2. t{char}    - "till" to jump before character
3. w / b      - word-based movement
4. H / L      - line start/end (custom config)
```

#### Medium Range (visible screen)
```
1. s{char}{char} - Leap to any visible spot
2. { / }         - Paragraph jumps
3. Ctrl-d/u      - Half-page scrolling
4. /pattern      - Search within view
```

#### Long Range (across file)
```
1. /pattern      - Search entire file
2. <leader>gd    - LSP definition jump
3. <leader>gr    - LSP references
4. [d / ]d       - Next/prev diagnostic
5. Ctrl-o/i      - Jump list back/forward
```

#### Cross-File
```
1. <leader>ff    - Telescope find files
2. <leader>fg    - Grep across project
3. <leader>1-4   - Harpoon marked files
4. <leader>b     - Buffer manager
```

### Advanced Recipes

#### Refactoring Workflow

**Rename variable across function**:
```vim
1. *                    " Search for word under cursor
2. cgn newName<Esc>    " Change next occurrence
3. .                    " Repeat for each occurrence
```
Or use LSP:
```vim
<leader>rn              " LSP rename (safer, scope-aware)
```

**Extract code to function**:
```vim
1. vip                  " Select paragraph
2. :s/oldVar/newVar/g   " Substitute in selection
```
For Java:
```vim
1. Visual select code
2. <leader>Jm           " Extract method (jdtls)
```

#### Quick Fixes

**Delete all lines matching pattern**:
```vim
:g/pattern/d
```

**Keep only lines matching pattern**:
```vim
:v/pattern/d
```

**Sort lines in visual selection**:
```vim
1. vip       " Select paragraph
2. :sort
```

#### Navigate Large Files

**Jump between functions** (using TreeSitter):
```vim
]f           " Next function
[f           " Previous function
]c           " Next class
```

**Center on function** (LSP):
```vim
<leader>gd   " Go to definition
zz           " Center screen
```

**Fold/unfold sections**:
```vim
za           " Toggle fold
zR           " Open all folds
zM           " Close all folds
```

### The Jump List

Vim remembers your navigation history:
- `Ctrl-o`: Jump to older position
- `Ctrl-i`: Jump to newer position
- `:jumps`: View jump list

**Pro tip**: After any big jump (`<leader>gd`, `/search`, etc.), use `Ctrl-o` to return.

### Marks (Location Bookmarks)

```vim
m{a-z}       " Set mark (local to buffer)
m{A-Z}       " Set mark (global across files)
'{mark}      " Jump to mark's line
`{mark}      " Jump to mark's exact position
:marks       " List all marks
```

**Workflow**:
```vim
ma           " Mark current position as 'a'
/search      " Do some navigation
'a           " Jump back to mark 'a'
```

### Macros (Record & Replay)

```vim
q{a-z}       " Start recording to register {a-z}
...commands...
q            " Stop recording
@{a-z}       " Replay macro
@@           " Repeat last macro
{count}@{a-z} " Replay macro {count} times
```

**Example - Format list items**:
```vim
qa           " Record to register 'a'
I- <Esc>     " Add "- " at line start
j            " Move down
q            " Stop recording
10@a         " Apply to next 10 lines
```

---

## LSP Integration

### Supported Languages

Your config includes comprehensive LSP support for:

| Language | Server | Features |
|----------|--------|----------|
| Python | basedpyright | Type checking, imports, refactoring |
| TypeScript/JavaScript | ts_ls | IntelliSense, refactoring, auto-imports |
| Rust | rust_analyzer | Clippy, auto-import, inlay hints |
| Go | gopls | Imports, refactoring, hints |
| C/C++ | clangd | Completion, diagnostics, formatting |
| Java | jdtls | Full IDE features, testing |
| Julia | julials | Linting, completion |
| CSS | cssls | Completion, validation |
| JSON/YAML | jsonls/yamlls | Schema validation |
| Kotlin | kotlin_language_server | Full support |
| Dart/Flutter | dartls | Via flutter-tools |

### LSP Features Deep Dive

#### Code Navigation Pattern

**The "Go To" Workflow**:
```vim
1. <leader>gh      " Hover to understand what you're on
2. <leader>gd      " Go to definition to see implementation
3. Ctrl-o          " Jump back when done
4. <leader>gr      " See all places this is used
```

**Cross-reference Pattern**:
```vim
1. <leader>gr      " Get all references in Telescope
2. <C-q>           " Send to quickfix
3. :copen          " Open quickfix window
4. <CR> on item    " Jump to reference
```

#### Code Actions

Trigger with `<leader>ca` on:
- Imports (add missing, remove unused)
- Quick fixes (implement interface, add type)
- Refactorings (extract function, inline variable)
- Lint fixes (auto-fix formatting issues)

**Example - Add import**:
```vim
1. Place cursor on undefined symbol
2. <leader>ca      " Show code actions
3. Select "Add import"
```

#### Inlay Hints

Shows inline type information:
```rust
let numbers = vec![1, 2, 3];  // : Vec<i32>
```

Toggle with `<leader>ih`.

**Languages with hints**:
- Rust: Types, parameter names
- TypeScript: Parameter names, return types
- Go: All hint types

#### Diagnostics Workflow

**Fix-on-save pattern**:
```vim
1. Write code (diagnostics appear)
2. [d / ]d         " Jump through errors
3. <leader>ca      " Apply quick fixes
4. <leader>f       " Format
5. <leader>w       " Save
```

**Review all issues**:
```vim
1. <leader>Q       " Send all diagnostics to quickfix
2. :copen          " Review list
3. Fix items one by one
```

---

## Workflow Optimization

### The Modal Editing Mindset

#### Think in Text Objects

❌ **Don't**: `dllllll` (delete 6 characters)
✅ **Do**: `dw` (delete word)

❌ **Don't**: `wwwwww` (move 6 words)
✅ **Do**: `/target<CR>` (search for target)

❌ **Don't**: `jjjjjj` (move down 6 lines)
✅ **Do**: `6j` or `}` (paragraph jump)

#### Stay in Normal Mode

Insert mode should be brief:
```vim
1. Enter insert mode (i, a, o, c)
2. Type your content
3. Immediately <Esc> or jk
```

If you're in insert mode for more than 5-10 seconds, you're probably doing it wrong.

#### Use Counts

```vim
3w           " Move 3 words forward
5j           " Move 5 lines down
2}           " Jump 2 paragraphs down
d3w          " Delete 3 words
3dd          " Delete 3 lines
y2ap         " Yank 2 paragraphs
```

### File Organization Strategy

#### Harpoon Workflow

**Per-feature development**:
```vim
1. Open main implementation file
   <leader>m         " Mark as #1
2. Open test file
   <leader>m         " Mark as #2
3. Open related component
   <leader>m         " Mark as #3
4. Open docs/notes
   <leader>m         " Mark as #4

Now toggle between them:
<leader>1/2/3/4    " Instant switching
```

**Why Harpoon > Buffer List**:
- Muscle memory (same keys every session)
- No cognitive load (you chose the order)
- No fuzzy finding delay

#### Telescope Workflow

**Quick file access**:
```vim
<leader>ff           " Find files
Type: impl user      " Fuzzy match "user_impl.rs"
```

**Project-wide search**:
```vim
<leader>fg           " Live grep
Type: fn handle      " Find "fn handle" anywhere
<C-q>                " Send to quickfix
:cdo s/old/new/g     " Replace in all results
```

**Buffer management**:
```vim
<leader>fb           " List buffers
<C-d>                " Preview + delete unwanted
```

### LSP-Driven Development

**The TDD Cycle with LSP**:
```vim
1. Write failing test
2. <leader>ca        " Generate function stub
3. <leader>gd        " Jump to implementation
4. Implement
5. <leader>f         " Format
6. :w                " Save (auto-runs tests if configured)
7. [d / ]d           " Check diagnostics
8. Ctrl-o            " Back to test
```

**Refactoring safely**:
```vim
1. <leader>rn        " LSP rename (refactor-safe)
2. Verify in Telescope preview
3. Confirm
4. <leader>gr        " Check all references updated
```

**Documentation lookup**:
```vim
1. <leader>gh        " Hover on symbol (quick docs)
2. K                 " Or use built-in hover (if remapped)
```

### Completion Optimization

**Let LSP do the work**:
```vim
1. Start typing
2. Wait 150ms (debounce)
3. Completion appears automatically
4. <Tab>/<S-Tab> to navigate
5. <CR> to accept
```

**For slow completions**:
```vim
<C-Space>            " Manual trigger
```

**Snippet workflow**:
```vim
1. Type trigger (e.g., "fn")
2. <CR> to expand snippet
3. <Tab> to jump between placeholders
4. Edit each placeholder
```

### Terminal Integration

**Quick commands**:
```vim
<leader>t            " Open terminal
git status           " Run command
<Esc> or jk          " Back to normal mode
<leader>q            " Close terminal
```

**Split terminal workflow**:
```vim
<leader>v            " Vertical split
<leader>t            " Terminal in split
npm run dev          " Start dev server
<C-h>                " Back to code
                     " Terminal stays running
```

---

## Plugin Maximization Strategies

### Telescope: The Hub

**Make it your command center**:

1. **File navigation**: `<leader>ff` (use fuzzy matching liberally)
2. **Text search**: `<leader>fg` (supports regex)
3. **Buffer switching**: `<leader>fb` (faster than cycling)
4. **Help lookup**: `<leader>fh` (search all help docs)

**Advanced Telescope**:
```vim
:Telescope lsp_document_symbols     " Navigate current file's symbols
:Telescope lsp_workspace_symbols    " Project-wide symbol search
:Telescope diagnostics              " All errors/warnings
:Telescope git_files                " Git-tracked files only
```

### Leap: Rethink Navigation

**Before Leap**:
```vim
/function<CR>        " Search
n                    " Next match
n                    " Next match
```

**With Leap**:
```vim
sfu                  " Jump directly (2 chars)
```

**Use cases**:
- Jump to function call: `s` + first 2 chars
- Navigate to specific word: `s` + 2 chars
- Jump across folds: `s` works anywhere visible

**Pro tip**: Use `s` as default medium-range navigation instead of searching.

### TreeSitter Text Objects: Structural Editing

**Thinking in syntax, not characters**:

```python
def calculate_price(base, discount, tax):
    subtotal = base - discount
    total = subtotal + tax
    return total
```

**Operations**:
```vim
daf              " Delete entire function (including signature)
dif              " Delete function body only
yaf              " Yank entire function
vif=             " Select and auto-format function body
]f               " Jump to next function
cia              " Change parameter (cursor on parameter)
```

**Swap parameters**:
```python
def foo(a, b, c):  # Cursor on 'b'
```
```vim
<leader>sp       " Now: def foo(a, c, b)
```

### LSP: Full IDE Experience

**Auto-import workflow**:
```typescript
// Type undefined symbol
const user = new User();  // Underlined in red
```
```vim
<leader>ca       " Show: "Add import for User"
<CR>             " Auto-adds: import { User } from './models'
```

**Rename across project**:
```vim
<leader>rn       " On symbol
newName<CR>      " Renames everywhere, updates imports
```

**Format on save** (add to config):
```lua
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.rs,*.go,*.ts,*.tsx",
  callback = function()
    vim.lsp.buf.format({ async = false })
  end
})
```

### Git Integration (via Far.vim)

**Project-wide refactoring**:
```vim
<leader>ffr                  " Start Far
:Far oldName newName **/*.js " Find and replace in all JS files
<leader>ffd                  " Execute (with preview)
```

**Safer than**:
```vim
:%s/old/new/g                " Only current file, no preview
```

### Buffer Manager: Quick Switching

**Faster than buffer cycling**:
```vim
<leader>b        " Open menu
2                " Jump to buffer #2 (instant)
```

Vs traditional:
```vim
:ls              " List buffers
:b2              " Switch to #2
```

### Quick Scope: Precision f/t

**Enhanced character jumping**:
```
The quick brown fox jumps over the lazy dog
```

With cursor at start:
```vim
fq               " Jump to 'q' (highlighted in pink)
ft               " Jump to first 't' (unique chars highlighted)
```

Quick-scope highlights the easiest targets automatically.

### Performance Tips for Large Files

**Your config automatically**:
- Disables TreeSitter for files >50MB
- Reduces LSP features for files >5MB
- Disables Git gutter for files >10MB

**Manual commands**:
```vim
:TSBufDisable highlight      " Disable syntax for current buffer
:TSStatus                    " Check TreeSitter status
:LspStop                     " Stop LSP for current buffer
```

---

## Putting It All Together

### Example Session: Building a Feature

```vim
# 1. Find the file
<leader>ff
Type: user_service
<CR>

# 2. Mark it for quick access
<leader>m              # Harpoon mark #1

# 3. Find related test
<leader>ff
Type: user_test
<CR>
<leader>m              # Harpoon mark #2

# 4. Jump to function to modify
/process_user<CR>      # Find function
<leader>gd             # Go to definition
vif                    # Select function body
y                      # Copy (backup)

# 5. Add new parameter
/def process_user<CR>
f)                     # Jump to closing paren
i, include_metadata: bool<Esc>  # Add param

# 6. Update callers
<leader>gr             # Find all references
<C-q>                  # Send to quickfix
:cfdo s/process_user()/process_user(True)/g

# 7. Format and test
<leader>f              # Format
<leader>1              # Harpoon back to main file
<leader>2              # Jump to test
<leader>ca             # Run test (language-specific)

# 8. Verify no errors
]d                     # Jump through diagnostics
<leader>Q              # Review all in quickfix
```

### Muscle Memory Development

**Week 1: Basic motions**
- Practice `w`, `b`, `e` instead of `l`, `h`
- Use `f{char}` for line navigation
- Force yourself: `jk` instead of `Esc`

**Week 2: Text objects**
- `ciw`, `caw` instead of `dwi`
- `dip`, `dap` instead of `dj`
- `ci"`, `ci{`, `cit` for pairs

**Week 3: Plugin integration**
- Use `s{char}{char}` instead of `/search`
- `<leader>ff` instead of `:e`
- `<leader>m` + `<leader>1-4` workflow

**Week 4: LSP workflow**
- `<leader>gd` + `Ctrl-o` pattern
- `<leader>rn` for renames
- `<leader>ca` for quick fixes

**Week 5+: Custom combos**
- Combine everything fluidly
- Develop your own patterns
- Contribute back to config!

### Configuration Customization

**Add your own keymaps** in `lua/core/keymaps.lua`:
```lua
-- Example: Quick save and format
vim.keymap.set('n', '<leader>W', function()
  vim.lsp.buf.format({ async = false })
  vim.cmd('write')
end, { desc = 'Format and save' })
```

**Adjust LSP settings** in `lua/plugins/init.lua`:
```lua
-- Example: Enable virtual text for diagnostics
vim.diagnostic.config({
  virtual_text = true,  -- Change from false
})
```

**Add more Telescope pickers**:
```lua
vim.keymap.set('n', '<leader>fs', '<cmd>Telescope lsp_document_symbols<cr>')
vim.keymap.set('n', '<leader>fw', '<cmd>Telescope lsp_workspace_symbols<cr>')
```

---

## Quick Reference Card

### Essential Commands (Print This!)

```
NORMAL MODE BASICS          LSP COMMANDS               PLUGINS
------------------          ------------               -------
jk         - Escape         <leader>gd  - Definition   <leader>ff - Find files
H/L        - Line start/end <leader>gr  - References   <leader>fg - Grep
J/K        - Paragraph jump <leader>rn  - Rename       <leader>e  - File tree
Ctrl-d/u   - Half page      <leader>ca  - Code action  <leader>b  - Buffers
f{char}    - Find char      [d / ]d     - Diagnostics  <leader>m  - Harpoon mark
s{c}{c}    - Leap jump      <leader>gh  - Hover docs   s{c}{c}    - Leap

TEXT OBJECTS                WINDOW/BUFFER              TERMINAL
------------                -------------              --------
ciw  - Change word          Ctrl-h/j/k/l - Navigate    <leader>t - Open term
ci"  - Change in quotes     <leader>v    - V-split     jk/Esc    - Exit term
dip  - Delete paragraph     <leader>s    - H-split     Ctrl-hjkl - Nav away
yap  - Yank paragraph       <leader>d    - Delete buf
vif  - Select function      <leader>[/]  - Prev/next buf
```

---

## Troubleshooting

### LSP not starting

```vim
:LspInfo                     # Check status
:Mason                       # Verify servers installed
:checkhealth                 # Full diagnostic
```

### Slow performance

```vim
:TSStatus                    # Check TreeSitter status
:LspStop                     # Stop LSP if needed
:TSBufDisable highlight      # Disable syntax highlighting
```

### Keybinding conflicts

```vim
:verbose map <leader>gd      # See what's mapped
:map                         # List all mappings
```

### Completion not working

```vim
:set completeopt?            # Should show menu,menuone,noselect
:CmpStatus                   # Check nvim-cmp status
```

---

## Resources

- **Neovim Docs**: `:help` + `<leader>fh` (Telescope help)
- **Plugin Docs**: `:help <plugin-name>` (e.g., `:help telescope`)
- **LSP Docs**: `:help lsp`
- **Vim Tutor**: Run `nvim +Tutor` for interactive tutorial
- **TreeSitter**: `:help nvim-treesitter`

---

## Conclusion

This configuration is designed for **speed and ergonomics**. The more you internalize these patterns, the faster you'll move. Focus on:

1. **Motions over arrows**: Think in text objects
2. **Leap for medium-range**: 2-4 keystrokes to anywhere
3. **LSP for intelligence**: Let the language server work for you
4. **Harpoon for context**: Mark your active files
5. **Telescope for discovery**: Fuzzy find everything

**Remember**: Vim is a language. The more you "speak" it, the more fluent you become. Start with the basics, add one new technique per week, and soon you'll be flying through code.

Happy coding! 🚀
