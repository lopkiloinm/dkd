const fs = require('fs');

function updateFile(file, appendCSS) {
  let content = fs.readFileSync(file, 'utf8');
  content = content.replace(/<style scoped lang="scss">[\s\S]*?@import "@\/styles\/_mixins\.scss";/, `<style scoped lang="scss">\n@import "@/styles/_variables.scss";\n@import "@/styles/_mixins.scss";\n${appendCSS}`);
  fs.writeFileSync(file, content);
}

updateFile('dkd-vue-uni-app/src/components/ui/Card.vue', `\n:host {\n  display: block;\n  height: 100%;\n}\n\n.card {\n  height: 100%;\n  box-sizing: border-box;\n`);
updateFile('dkd-vue-uni-app/src/components/app/SectionCard.vue', `\n:host {\n  display: block;\n  height: 100%;\n}\n`);
