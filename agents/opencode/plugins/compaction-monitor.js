import { existsSync, readFileSync } from 'node:fs'
import { homedir } from 'node:os'
import { join } from 'node:path'
import { execFileSync } from 'node:child_process'

function readJson(path) {
  try {
    return JSON.parse(readFileSync(path, 'utf8'))
  } catch {
    return undefined
  }
}

function repoRoot(cwd) {
  try {
    return execFileSync('git', ['rev-parse', '--show-toplevel'], { cwd, encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore'] }).trim()
  } catch {
    return ''
  }
}

function config(cwd) {
  const homePath = join(homedir(), '.compaction-monitor.json')
  if (existsSync(homePath)) return readJson(homePath)
  const root = repoRoot(cwd)
  const repoPath = root ? join(root, '.compaction-monitor.json') : ''
  if (repoPath && existsSync(repoPath)) return readJson(repoPath)
  return undefined
}

function contextWarning(cfg) {
  const usage = readJson(join(homedir(), '.claude', 'token_usage.json')) ?? {}
  const utilization = Math.floor(Number(usage.utilization_pct ?? 0))
  const alert = String(usage.alert_level ?? 'NORMAL')
  const compactCountPath = join(homedir(), '.claude', 'compaction-count.txt')
  const compactions = existsSync(compactCountPath) ? Number.parseInt(readFileSync(compactCountPath, 'utf8'), 10) || 0 : 0

  const warnUtil = Number(cfg.warn_utilization_pct ?? 75)
  const criticalUtil = Number(cfg.critical_utilization_pct ?? 90)
  const warnCompactions = Number(cfg.warn_compaction_count ?? 2)
  const criticalCompactions = Number(cfg.critical_compaction_count ?? 4)

  const critical = utilization >= criticalUtil || compactions >= criticalCompactions || ['WARNING', 'CRITICAL'].includes(alert)
  const warning = critical || utilization >= warnUtil || compactions >= warnCompactions || alert === 'CAUTION'
  if (!warning) return ''

  const level = critical ? 'WARNING' : 'CAUTION'
  return `[Compaction Monitor ${level}: context utilization ${utilization}%, compactions ${compactions}. Consider reducing task scope, writing a handoff, or starting a fresh session before quality degrades.]`
}

function append(output, text) {
  if (!text) return
  if (Array.isArray(output?.context)) output.context.push(text)
  else if (typeof output?.prompt === 'string') output.prompt += `\n\n${text}`
  else if (typeof output?.text === 'string') output.text += `\n\n${text}`
  else if (output) output.context = [text]
}

export const CompactionMonitorPlugin = async ({ client, directory, worktree } = {}) => {
  await client?.app?.log?.({ body: { service: 'compaction-monitor', level: 'info', message: 'plugin initialized' } })
  return {
  'tui.prompt.append': async (_input, output) => {
    const cfg = config(worktree ?? directory ?? process.cwd())
    if (!cfg || cfg.enabled === false) return
    append(output, contextWarning(cfg))
  },
  'experimental.session.compacting': async (_input, output) => {
    const cfg = config(worktree ?? directory ?? process.cwd())
    if (!cfg || cfg.enabled === false) return
    append(output, contextWarning(cfg))
  },
  }
}