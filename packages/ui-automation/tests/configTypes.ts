import { Browser, Page } from "playwright";

declare global {
  const page: Page;
  const browser: Browser;
  const browserName: string;
}

export const endpoint = {
  // Use docker container name inside Docker, fallback to localhost for local dev
  BASE_URL: process.env.BASE_URL || "http://localhost:3000",
};
