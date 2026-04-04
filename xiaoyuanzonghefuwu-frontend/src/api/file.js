import request from './request'

const normalizeUploadPath = (rawPath) => {
  if (!rawPath) return ''
  if (/^https?:\/\//i.test(rawPath)) return rawPath
  if (rawPath.startsWith('/upload/')) return rawPath
  if (rawPath.startsWith('upload/')) return `/${rawPath}`
  return `/upload/${rawPath}`
}

export function uploadImage(file) {
  const formData = new FormData()
  formData.append('file', file)
  return request({
    url: '/file/upload',
    method: 'post',
    data: formData,
    headers: {
      'Content-Type': 'multipart/form-data'
    }
  }).then((res) => ({
    ...res,
    file: normalizeUploadPath(res?.file || res?.data?.file || '')
  }))
}
