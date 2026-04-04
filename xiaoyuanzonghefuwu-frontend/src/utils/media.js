export const FORUM_IMAGE_TOKEN = '[img]'

const FORUM_IMAGE_REGEX = /\[img\](\S+)/g

export function resolveFileUrl(path) {
  if (!path) return ''
  if (/^https?:\/\//i.test(path)) return path
  if (path.startsWith('/xiaoyuanzonghefuwu/')) return path
  if (path.startsWith('/upload/')) return `/xiaoyuanzonghefuwu${path}`
  if (path.startsWith('upload/')) return `/xiaoyuanzonghefuwu/${path}`
  return `/xiaoyuanzonghefuwu/upload/${path}`
}

export function extractImagesFromForumContent(content = '') {
  const list = []
  const normalized = String(content || '')
  for (const match of normalized.matchAll(FORUM_IMAGE_REGEX)) {
    list.push(resolveFileUrl(match[1]))
  }
  return list
}

export function stripForumImageTokens(content = '') {
  return String(content || '')
    .replace(/\[img\]\S+/g, '')
    .replace(/\n{3,}/g, '\n\n')
    .trim()
}

export function buildForumContent(text = '', imagePaths = []) {
  const lines = []
  const cleanText = String(text || '').trim()
  if (cleanText) {
    lines.push(cleanText)
  }
  imagePaths
    .filter(Boolean)
    .forEach((path) => {
      lines.push(`${FORUM_IMAGE_TOKEN}${path}`)
    })
  return lines.join('\n')
}
