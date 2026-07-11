import { describe, expect, test } from "bun:test"

describe("smoke", () => {
  test("environment is sane", () => {
    expect(true).toBe(true)
  })

  test("basic arithmetic", () => {
    expect(1 + 1).toBe(2)
  })
})
