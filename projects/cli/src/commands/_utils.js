let { version } = require('../../package.json')

const Terminal = {
  bold: (str) => '\033[1m' + str + '\033[0m',
  dim: (str) => '\033[2m' + str + '\033[0m',
  red: (str) => '\033[31m' + str + '\033[0m',
  green: (str) => '\033[32m' + str + '\033[0m',
  pink: (str) => '\033[35m' + str + '\033[0m',
  cyan: (str) => '\033[36m' + str + '\033[0m',
}

const stripAnsi = (str) =>
  str.replace(/[\u001b\u009b][[()#;?]*(?:[0-9]{1,4}(?:;[0-9]{0,4})*)?[0-9A-ORZcf-nqry=><]/g, '')

let name =
  `Elm Land ${Terminal.dim(`(v${version})`)}`

const intro = {

  // Show header with green underline
  success: (message) => [
    `🌈  ${name} ${message}`,
    Terminal.green('    ' + '⎺'.repeat(stripAnsi(message).length + stripAnsi(name).length + 1))
  ].join('\n'),

  // Show header with red underline
  error: (message) => [
    `🌈  ${name} ${message}`,
    Terminal.red('    ' + '⎺'.repeat(stripAnsi(message).length + stripAnsi(name).length + 1))
  ].join('\n')
}

let didNotRecognizeCommand = ({ baseCommand, subCommand, subcommandList }) => [
  '',
  subCommand === undefined
    ? intro.error(`expected more arguments for ${Terminal.cyan(baseCommand)}`)
    : intro.error(`couldn't find an ${Terminal.cyan(`${baseCommand} ${subCommand}`)} command`),
  ...subcommandList,
  '',
].join('\n')

let notInElmLandProject = [
  '',
  intro.error(`${Terminal.cyan('couldn\'t find a project')} in this folder`),
  `    Please try again in the folder with your ${Terminal.cyan('elm-land.json')} file`,
  '',
  `    If you'd like to start a new project, run this command: `,
  '',
  `    elm-land ${Terminal.pink('init <folder>')} .... create a new project`,
  '',
].join('\n')

let customizableFiles = {
  'shared': {
    filepath: 'Shared.elm',
    description: '.................... share data across pages'
  },
  'not-found': {
    filepath: 'Pages/NotFound_.elm',
    description: '... the 404 page shown for unknown routes'
  },
  'view': {
    filepath: 'View.elm',
    description: '................ use Elm UI, Elm CSS, and more'
  },
  'effect': {
    filepath: 'Effect.elm',
    description: '............. send custom effects from pages'
  },
  'auth': {
    filepath: 'Auth.elm',
    description: '................... handle user authentication'
  },
}

module.exports = {
  Terminal,
  Utils: {
    intro,
    didNotRecognizeCommand,
    notInElmLandProject,
    customizableFiles
  }
}

