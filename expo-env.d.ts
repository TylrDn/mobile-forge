/// <reference types="expo/types" />

// Augment CSS module imports used by NativeWind
declare module "*.css" {
  const content: string
  export default content
}
