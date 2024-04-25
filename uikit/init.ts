// @ts-ignore
import { Elm } from "./.elm-land/src/Main.elm";

// @ts-ignore
if (process.env.NODE_ENV === "development") {
  const ElmDebugTransform = await import("elm-debug-transformer");

  ElmDebugTransform.register({});
}

(async () => {
  const rootNode = document.querySelector("#app div") as HTMLDivElement;
  const app = Elm.Main.init({
    flags: {
      windowSize: {
        height: window.innerHeight,
        width: window.innerWidth,
      },
    },
    node: rootNode,
  });

  app.ports.urlChanged.subscribe((_val) => {
    window.scrollTo(0, 0);
  });
})().catch(() => (window.location.href = "/error.html"));
