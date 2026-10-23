import { notificationMessage } from "./messages.ts";
Deno.test("localizes events and falls back to English", () => {
  if (
    notificationMessage("it", "like", "Alice", {}).body !==
      "Ha messo Mi piace al tuo post"
  ) throw new Error("Italian translation missing");
  if (
    notificationMessage("fr", "comment", "Bob", {}).body !==
      "Commented on your post"
  ) throw new Error("Fallback missing");
  if (
    !notificationMessage("it", "report_status", "", { status: "resolved" }).body
      .endsWith("Risolta")
  ) throw new Error("Status translation missing");
  if (notificationMessage("it", "report_status", "", {}).title !== "GymBro") {
    throw new Error("System actor missing");
  }
});
