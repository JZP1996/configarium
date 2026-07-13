import { createHash } from 'node:crypto'

const TRIP_THRESHOLD = 3
const failures = new Map()

function stable(value) {
  if (Array.isArray(value)) return value.map(stable)
  if (value && typeof value === 'object') {
    return Object.fromEntries(Object.keys(value).sort().map((key) => [key, stable(value[key])]))
  }
  return value
}

function argsOf(input, output) {
  return output?.args ?? input?.args ?? input?.input ?? {}
}

function fingerprint(input, output) {
  const tool = String(input?.tool ?? input?.name ?? 'unknown')
  return createHash('md5').update(`${tool}:${JSON.stringify(stable(argsOf(input, output)))}`).digest('hex')
}

function resultText(value) {
  if (value == null) return ''
  if (typeof value === 'string') return value
  if (typeof value === 'object') {
    return [value.error, value.stderr, value.stdout, value.output, value.content, value.message, JSON.stringify(value)].filter(Boolean).join('\n').slice(0, 3000)
  }
  return String(value)
}

function hasFailure(text, output) {
  if (output?.error) return true
  const exit = text.match(/[Ee]xit\s*[Cc]ode\s*:?\s*([0-9]+)/)
  if (exit) return exit[1] !== '0'
  return ['command not found', 'No such file or directory', 'Permission denied', 'Connection refused', 'fatal:', 'ENOENT', 'EACCES', 'EPERM', 'Traceback', 'panic:'].some((pattern) => text.includes(pattern))
}

function transient(text) {
  return [/429.*rate/i, /status\s*:?\s*429/i, /ETIMEDOUT|ECONNRESET|ECONNREFUSED|ENETUNREACH|ENOTFOUND/, /retry-after/i, /getaddrinfo|DNS resolution|Temporary failure in name resolution/i, /502|503|Bad Gateway|Service Unavailable/i].some((pattern) => pattern.test(text))
}

export const CircuitBreakerPlugin = async ({ client } = {}) => {
  await client?.app?.log?.({ body: { service: 'circuit-breaker', level: 'info', message: 'plugin initialized' } })
  return {
  'tool.execute.before': async (input, output) => {
    const argsText = JSON.stringify(argsOf(input, output))
    if (argsText.includes('circuit-breaker: override')) return

    const fp = fingerprint(input, output)
    const entry = failures.get(fp)
    if (entry?.count >= TRIP_THRESHOLD) {
      throw new Error(`Circuit breaker tripped: this tool call has failed ${entry.count} consecutive times. Try a different approach. Last error: ${entry.error || 'unknown'}. Add 'circuit-breaker: override' to bypass intentionally.`)
    }
  },
  'tool.execute.after': async (input, output) => {
    const fp = fingerprint(input, output)
    const text = resultText(output?.result ?? output?.output ?? output)
    if (!hasFailure(text, output) || transient(text)) {
      failures.delete(fp)
      return
    }

    const previous = failures.get(fp)?.count ?? 0
    const next = { count: previous + 1, error: text.split('\n').find(Boolean)?.slice(0, 160) ?? 'unknown' }
    failures.set(fp, next)

    if (next.count >= 2 && client?.app?.log) {
      await client.app.log({ body: { service: 'circuit-breaker', level: 'warn', message: `consecutive failure #${next.count}; breaker trips at ${TRIP_THRESHOLD}` } })
    }
  },
  }
}