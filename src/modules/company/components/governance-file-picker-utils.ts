export function governanceUploadFileKey(file: File) {
  return `${file.name}:${file.size}:${file.lastModified}`
}
