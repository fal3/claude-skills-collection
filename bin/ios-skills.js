#!/usr/bin/env node

/**
 * Claude iOS Skills CLI
 * =====================
 * 
 * Simple command-line tool to install and manage iOS/Swift skills for Claude AI.
 * 
 * Usage:
 *   npx claude-ios-skills list                    # List all available skills
 *   npx claude-ios-skills install <skill-name>   # Install a specific skill
 *   npx claude-ios-skills copy <skill-name>       # Copy skill to clipboard
 *   npx claude-ios-skills search <keyword>        # Search skills by keyword
 *   npx claude-ios-skills                        # Interactive mode
 */

const { Command } = require('commander');
const chalk = require('chalk');
const inquirer = require('inquirer');
const clipboardy = require('clipboardy');
const fs = require('fs');
const path = require('path');
const https = require('https');

const program = new Command();

// Configuration
const SKILLS_BASE_URL = 'https://raw.githubusercontent.com/fal3/claude-skills-collection/main';
const INSTALL_DIR = path.join(require('os').homedir(), '.claude', 'skills');

// Available skills with metadata
const SKILLS = [
  {
    id: 'swiftui-programming-skill',
    name: 'SwiftUI Programming',
    description: 'SwiftUI declarative UI development, SF Symbols, state management',
    keywords: ['swiftui', 'ui', 'declarative', 'state', 'binding']
  },
  {
    id: 'swift-modern-architecture-skill',
    name: 'Swift Modern Architecture',
    description: 'Swift 6/iOS 18 architecture patterns, SwiftData, Observation framework',
    keywords: ['architecture', 'swiftdata', 'observation', 'modern', 'patterns']
  },
  {
    id: 'ios-accessibility-skill',
    name: 'iOS Accessibility',
    description: 'VoiceOver, Dynamic Type, HIG compliance',
    keywords: ['accessibility', 'voiceover', 'dynamic type', 'a11y']
  },
  {
    id: 'swift-performance-optimization-skill',
    name: 'Performance Optimization',
    description: 'Performance profiling, Instruments usage, memory efficiency',
    keywords: ['performance', 'optimization', 'instruments', 'profiling']
  },
  {
    id: 'cross-platform-app-development-skill',
    name: 'Cross-Platform Development',
    description: 'Multi-platform app strategies for iOS, iPadOS, macOS',
    keywords: ['cross-platform', 'ipad', 'macos', 'multi-platform']
  },
  {
    id: 'swift-unit-testing-skill',
    name: 'Unit Testing',
    description: 'XCTest framework, TDD, mocking patterns',
    keywords: ['testing', 'xctest', 'tdd', 'unit tests']
  },
  {
    id: 'ios-animation-graphics-skill',
    name: 'Animation & Graphics',
    description: 'SwiftUI Canvas, Lottie animations, custom graphics',
    keywords: ['animation', 'graphics', 'canvas', 'lottie']
  },
  {
    id: 'memory-leak-diagnosis-skill',
    name: 'Memory Leak Diagnosis',
    description: 'ARC, retain cycles, Instruments Leaks tool',
    keywords: ['memory', 'leak', 'arc', 'retain cycle', 'instruments']
  }
];

// Utility functions
function createInstallDir() {
  if (!fs.existsSync(INSTALL_DIR)) {
    fs.mkdirSync(INSTALL_DIR, { recursive: true });
  }
}

function downloadSkill(skillId) {
  return new Promise((resolve, reject) => {
    const url = `${SKILLS_BASE_URL}/${skillId}/SKILL.md`;
    const filePath = path.join(INSTALL_DIR, `${skillId}.md`);
    
    console.log(chalk.blue(`📥 Downloading ${skillId}...`));
    
    https.get(url, (response) => {
      if (response.statusCode === 200) {
        const fileStream = fs.createWriteStream(filePath);
        response.pipe(fileStream);
        
        fileStream.on('finish', () => {
          fileStream.close();
          console.log(chalk.green(`✅ Successfully installed ${skillId}`));
          console.log(chalk.cyan(`📍 Location: ${filePath}`));
          resolve(filePath);
        });
      } else {
        reject(new Error(`Failed to download: ${response.statusCode}`));
      }
    }).on('error', reject);
  });
}

function copySkillToClipboard(skillId) {
  const filePath = path.join(INSTALL_DIR, `${skillId}.md`);
  
  if (!fs.existsSync(filePath)) {
    console.log(chalk.yellow(`⚠️  Skill not installed locally. Downloading first...`));
    return downloadSkill(skillId).then(() => {
      const content = fs.readFileSync(filePath, 'utf8');
      clipboardy.writeSync(content);
      console.log(chalk.green(`✓ Skill content copied to clipboard!`));
      console.log(chalk.cyan(`Paste it into your Claude conversation to activate the skill.`));
    });
  } else {
    const content = fs.readFileSync(filePath, 'utf8');
    clipboardy.writeSync(content);
    console.log(chalk.green(`✓ Skill content copied to clipboard!`));
    console.log(chalk.cyan(`Paste it into your Claude conversation to activate the skill.`));
  }
}

// Commands
function listSkills() {
  console.log(chalk.bold.blue('\n🍎 Claude iOS Skills Collection'));
  console.log(chalk.cyan('='.repeat(60)));
  console.log(chalk.gray('Expert iOS/Swift skills for Claude AI\n'));
  
  SKILLS.forEach((skill, index) => {
    console.log(chalk.bold(`${index + 1}. ${skill.name}`));
    console.log(chalk.gray(`   ID: ${skill.id}`));
    console.log(chalk.green(`   ${skill.description}`));
    console.log(chalk.yellow(`   Keywords: ${skill.keywords.join(', ')}`));
    console.log();
  });
  
  console.log(chalk.cyan('='.repeat(60)));
  console.log(chalk.gray(`Total skills: ${SKILLS.length}\n`));
}

function installSkill(skillId) {
  const skill = SKILLS.find(s => s.id === skillId);
  if (!skill) {
    console.log(chalk.red(`❌ Skill '${skillId}' not found.`));
    console.log(chalk.cyan('Use "npx claude-ios-skills list" to see available skills.'));
    return;
  }
  
  createInstallDir();
  
  downloadSkill(skillId)
    .then(() => {
      console.log(chalk.green('\n🎉 Installation complete!'));
      console.log(chalk.cyan('\nTo use this skill:'));
      console.log(chalk.white('1. Copy the content from the installed file'));
      console.log(chalk.white('2. Paste it into your Claude conversation'));
      console.log(chalk.white('3. Start asking iOS/Swift questions!'));
    })
    .catch((error) => {
      console.log(chalk.red(`❌ Installation failed: ${error.message}`));
    });
}

function copySkill(skillId) {
  const skill = SKILLS.find(s => s.id === skillId);
  if (!skill) {
    console.log(chalk.red(`❌ Skill '${skillId}' not found.`));
    console.log(chalk.cyan('Use "npx claude-ios-skills list" to see available skills.'));
    return;
  }
  
  createInstallDir();
  copySkillToClipboard(skillId);
}

function searchSkills(keyword) {
  const keywordLower = keyword.toLowerCase();
  const matches = SKILLS.filter(skill => 
    skill.name.toLowerCase().includes(keywordLower) ||
    skill.description.toLowerCase().includes(keywordLower) ||
    skill.keywords.some(k => k.toLowerCase().includes(keywordLower))
  );
  
  if (matches.length === 0) {
    console.log(chalk.yellow(`No skills found matching '${keyword}'.`));
    return;
  }
  
  console.log(chalk.bold.blue(`\n🔍 Search Results for '${keyword}':`));
  console.log(chalk.cyan('='.repeat(60)));
  
  matches.forEach(skill => {
    console.log(chalk.bold(`${skill.name}`));
    console.log(chalk.gray(`   ID: ${skill.id}`));
    console.log(chalk.green(`   ${skill.description}`));
    console.log();
  });
  
  console.log(chalk.cyan(`Found ${matches.length} matching skill(s).\n`));
}

async function interactiveMode() {
  console.log(chalk.bold.blue('\n🍎 Claude iOS Skills - Interactive Mode'));
  console.log(chalk.cyan('='.repeat(50)));
  
  const { action } = await inquirer.prompt([
    {
      type: 'list',
      name: 'action',
      message: 'What would you like to do?',
      choices: [
        { name: '📋 List all skills', value: 'list' },
        { name: '📥 Install a skill', value: 'install' },
        { name: '📋 Copy skill to clipboard', value: 'copy' },
        { name: '🔍 Search skills', value: 'search' },
        { name: '❌ Exit', value: 'exit' }
      ]
    }
  ]);
  
  switch (action) {
    case 'list':
      listSkills();
      break;
      
    case 'install':
      const { skillToInstall } = await inquirer.prompt([
        {
          type: 'list',
          name: 'skillToInstall',
          message: 'Which skill would you like to install?',
          choices: SKILLS.map(skill => ({
            name: `${skill.name} - ${skill.description}`,
            value: skill.id
          }))
        }
      ]);
      installSkill(skillToInstall);
      break;
      
    case 'copy':
      const { skillToCopy } = await inquirer.prompt([
        {
          type: 'list',
          name: 'skillToCopy',
          message: 'Which skill would you like to copy?',
          choices: SKILLS.map(skill => ({
            name: `${skill.name} - ${skill.description}`,
            value: skill.id
          }))
        }
      ]);
      copySkill(skillToCopy);
      break;
      
    case 'search':
      const { searchTerm } = await inquirer.prompt([
        {
          type: 'input',
          name: 'searchTerm',
          message: 'Enter search keyword:'
        }
      ]);
      searchSkills(searchTerm);
      break;
      
    case 'exit':
      console.log(chalk.green('👋 Thanks for using Claude iOS Skills!'));
      break;
  }
}

// CLI setup
program
  .name('claude-ios-skills')
  .description('Curated iOS/Swift skills for Claude AI')
  .version('1.0.0');

program
  .command('list')
  .description('List all available iOS skills')
  .action(listSkills);

program
  .command('install <skill-name>')
  .description('Install a specific skill')
  .action(installSkill);

program
  .command('copy <skill-name>')
  .description('Copy skill content to clipboard')
  .action(copySkill);

program
  .command('search <keyword>')
  .description('Search skills by keyword')
  .action(searchSkills);

program
  .action(interactiveMode);

program.parse();
