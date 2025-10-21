# Memory Leak Diagnosis Skill

This skill provides expertise in identifying, diagnosing, and fixing memory leaks and retain cycles in Swift applications using Instruments and ARC best practices.

## Activation

This skill activates automatically for queries related to:
- Memory leaks and retain cycles
- Instruments Leaks and Allocations usage
- ARC (Automatic Reference Counting) concepts
- Weak and unowned references
- Memory Graph Debugger analysis
- Reference counting issues

## Setup

To use this skill effectively:

1. Enable zombies in your scheme for debugging (Edit Scheme > Run > Diagnostics > Memory Management)
2. Use Product > Profile to access Instruments tools
3. Familiarize yourself with weak/unowned keywords and capture lists
4. Learn to interpret memory graphs and reference cycles

## Examples

See the `examples/` directory for sample code and prompts demonstrating memory leak diagnosis and fixes.

## Resources

- [Memory Management in Swift](https://docs.swift.org/swift-book/LanguageGuide/AutomaticReferenceCounting.html)
- [Instruments User Guide](https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/InstrumentsUserGuide/)
- [Debugging Memory Issues](https://developer.apple.com/library/archive/documentation/Performance/Conceptual/ManagingMemory/)