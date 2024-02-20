const { readFile, writeFile, mkdir } = require('fs/promises');
const path = require('path');

const saveStyles = async (themePath, prefix, targetPath = '/css') => {
  const target = path.join(process.cwd(), targetPath);
  const content = await readFile(path.join(process.cwd(), 'node_modules', themePath));

  const targetThemePath = path.join(target, themePath);
  await mkdir(path.dirname(targetThemePath), { recursive: true });

  const styleContent = prefix ? `.${prefix} {  ${content} }` : content;
  await writeFile(targetThemePath, styleContent, { encoding: 'utf-8', flag: 'w+' });
};

saveStyles('highlight.js/styles/github.css');
saveStyles('highlight.js/styles/github-dark.css', 'dark');
