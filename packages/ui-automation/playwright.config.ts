/// <reference types="node" />
import { defineConfig, devices } from "@playwright/test";

// Logging the environment variable to debug
console.log(`Using BASE_URL: ${process.env.BASE_URL || "http://nextjs:3000"}`);

export default defineConfig({
  testDir: "./tests",
  fullyParallel: false,
  forbidOnly: false,
  retries: 2,
  workers: 1,
  reporter: [["html"], ["json", { outputFile: "test-results/results.json" }]],
  use: {
    // Inside Docker container, we access nextjs via container name
    baseURL: process.env.BASE_URL || "http://localhost:3000",
    trace: "on",
    video: "on",
    screenshot: "on",
    actionTimeout: 45000,
    navigationTimeout: 90000,
    launchOptions: {
      headless: true,
      slowMo: 1000, // Increase slowMo for more stability
      args: [
        "--no-sandbox",
        "--disable-setuid-sandbox",
        "--disable-dev-shm-usage",
        "--disable-gpu",
        "--disable-web-security",
        "--disable-features=IsolateOrigins,site-per-process",
        "--no-first-run",
        "--no-default-browser-check",
      ],
    },
    viewport: { width: 1280, height: 720 },
    ignoreHTTPSErrors: true,
  },
  projects: [
    {
      name: "chromium",
      use: {
        ...devices["Desktop Chrome"],
        contextOptions: {
          acceptDownloads: true,
          bypassCSP: true,
        },
      },
    },
  ],
  timeout: 300000,
  expect: {
    timeout: 60000,
    toHaveScreenshot: { maxDiffPixelRatio: 0.1 },
  },
  preserveOutput: "always",
});
