module.exports = {
  root: true,
  env: {
    node: true,
    es2022: true,
  },
  parser: '@typescript-eslint/parser',
  parserOptions: {
    project: ['./tsconfig.json'],
    sourceType: 'script',
  },
  plugins: ['@typescript-eslint', 'import'],
  extends: ['eslint:recommended', 'google', 'plugin:@typescript-eslint/recommended'],
  rules: {
    'require-jsdoc': 'off',
    'valid-jsdoc': 'off',
    'max-len': ['error', { code: 120 }],
    '@typescript-eslint/no-explicit-any': 'off',
  },
};
