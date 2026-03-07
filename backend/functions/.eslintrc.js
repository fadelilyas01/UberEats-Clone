module.exports = {
    root: true,
    env: {
        es6: true,
        node: true,
    },
    extends: [
        "eslint:recommended",
        "plugin:@typescript-eslint/recommended",
    ],
    parser: "@typescript-eslint/parser",
    parserOptions: {
        project: ["tsconfig.json"],
        sourceType: "module",
    },
    ignorePatterns: [
        "/lib/**/*",
        "/node_modules/**/*",
        ".eslintrc.js",
    ],
    plugins: [
        "@typescript-eslint",
        "import",
    ],
    rules: {
        "@typescript-eslint/no-explicit-any": "off",
        "@typescript-eslint/no-unused-vars": "off",
        "import/no-unresolved": 0,
        "indent": "off",
        "max-len": "off",
        "quotes": ["warn", "single"],
    },
};
