const { readFile, writeFile, mkdir } = require('fs/promises');
const path = require('path');
const esbuild = require("esbuild");

const args = process.argv.slice(2);
const watch = args.includes('--watch');
const deploy = args.includes('--deploy');



const saveStyles = async (themePath, prefix, targetPath = '/css') => {
  const target = path.join(process.cwd(), targetPath);
  const content = await readFile(path.join(process.cwd(), 'node_modules', themePath));

  const targetThemePath = path.join(target, themePath);
  await mkdir(path.dirname(targetThemePath), { recursive: true });

  const styleContent = prefix ? `.${prefix} {  ${content} }` : content;
  await writeFile(targetThemePath, styleContent, { encoding: 'utf-8', flag: 'w+' });
};


const loader = {};
const plugins = [];

// Define esbuild options
let opts = {
  entryPoints: ["js/app.js"],
  bundle: true,
  logLevel: "info",
  target: "es2017",
  outdir: "../priv/static/assets",
  external: ["*.css", "fonts/*", "images/*"],
  loader: loader,
  plugins: plugins,
};

if (deploy) {
  opts = {
    ...opts,
    minify: true,
  };
}

saveStyles('highlight.js/styles/github.css');
saveStyles('highlight.js/styles/github-dark.css', 'dark');

if (watch) {
  opts = {
    ...opts,
    sourcemap: "inline",
  };
  esbuild
    .context(opts)
    .then((ctx) => {
      ctx.watch();
    })
    .catch((_error) => {
      process.exit(1);
    });
} else {
  esbuild.build(opts);
}
