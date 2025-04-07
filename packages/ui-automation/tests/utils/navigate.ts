import { Page } from "@playwright/test";
import { endpoint } from "../configTypes";

/**
 * Navigate to a URL and wait for the page to be stable
 *
 * @param page Playwright page object
 * @param url URL to navigate to
 * @param options Additional options
 */
export async function navigateAndWait(
  page: Page,
  url: string,
  options?: { timeout?: number; retries?: number },
) {
  // Transform localhost:3000 URLs to use the correct container name in Docker
  let targetUrl = url;
  // if (url.includes("localhost:3000")) {
  //   targetUrl = url.replace("localhost:3000", "nextjs:3000");
  //   console.log(
  //     `URL transformed for Docker environment: ${url} -> ${targetUrl}`,
  //   );
  // }

  // Always use the BASE_URL from environment if this is the base URL
  if (url === "http://localhost:3000" || url === "/") {
    targetUrl = endpoint.BASE_URL;
    console.log(`Using BASE_URL from environment: ${targetUrl}`);
  }

  console.log(`Navigating to: ${targetUrl}`);

  // Increase navigation timeout
  const timeout = options?.timeout || 30000;
  const maxRetries = options?.retries || 3;

  let retryCount = 0;
  let lastError: Error | null = null;

  while (retryCount < maxRetries) {
    try {
      if (retryCount > 0) {
        console.log(
          `Retry attempt ${retryCount}/${maxRetries} for navigation to ${targetUrl}`,
        );
        // Wait before retry
        await page.waitForTimeout(2000);
      }

      // Go to the URL with increased timeout
      await page.goto(targetUrl, {
        waitUntil: "domcontentloaded",
        timeout,
      });

      // Additional waits to ensure page stability
      await page.waitForLoadState("networkidle", { timeout });

      // Small additional delay for any dynamic content
      await page.waitForTimeout(2000);

      console.log(`Successfully navigated to: ${targetUrl}`);
      return; // Success, exit the function
    } catch (error) {
      lastError = error as Error;
      console.error(
        `Navigation attempt ${retryCount + 1} failed to: ${targetUrl}`,
      );
      console.error(error);
      retryCount++;
    }
  }

  // If we get here, all retries failed
  console.error(`All ${maxRetries} navigation attempts to ${targetUrl} failed`);
  if (lastError) {
    throw lastError;
  } else {
    throw new Error(
      `Failed to navigate to ${targetUrl} after ${maxRetries} attempts`,
    );
  }
}
