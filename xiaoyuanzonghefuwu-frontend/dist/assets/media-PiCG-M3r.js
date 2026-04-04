const u="[img]",i=/\[img\](\S+)/g;function s(n){return n?/^https?:\/\//i.test(n)||n.startsWith("/xiaoyuanzonghefuwu/")?n:n.startsWith("/upload/")?`/xiaoyuanzonghefuwu${n}`:n.startsWith("upload/")?`/xiaoyuanzonghefuwu/${n}`:`/xiaoyuanzonghefuwu/upload/${n}`:""}function a(n=""){const t=[],r=String(n||"");for(const o of r.matchAll(i))t.push(s(o[1]));return t}function c(n=""){return String(n||"").replace(/\[img\]\S+/g,"").replace(/\n{3,}/g,`

`).trim()}function f(n="",t=[]){const r=[],o=String(n||"").trim();return o&&r.push(o),t.filter(Boolean).forEach(e=>{r.push(`${u}${e}`)}),r.join(`
`)}export{f as b,a as e,s as r,c as s};
