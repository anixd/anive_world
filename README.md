# AniveWorld

`AniveWorld` is a web application designed for the comprehensive management of a fictional world (worldbuilding) and its languages (conlanging). The platform serves as a unified hub for maintaining dictionaries, an encyclopedia, a timeline, character biographies, and other materials related to the world you create.

The platform is designed to manage the world and its languages that I am working on. But of course, it can be used for any fictional world and its languages.

## Features & Architecture

The application is based on a flexible and scalable architecture built on modern Ruby on Rails practices.

### Linguistic Core

* **Dictionaries based on `Lexeme` & `Word` (STI):** The central dictionary architecture separates the "spelling" of a word (`Lexeme`) from its "meaning" (`Word`). This allows for an elegant way to handle *homonyms* (one spelling, multiple meanings).
* **Language Hierarchy:** The `Language` model supports nesting, allowing for the definition of language families and dialects.
* **Flexible Morphology:** Roots (`Root`) and affixes (`Affix`) are fully-fledged models tied to specific languages. Words can be composed of multiple roots.
* **Multiple Parts of Speech:** A word can belong to several parts of speech simultaneously (a many-to-many relationship).
* **Etymology and Synonyms:** The system supports tracking word origins (including from ancestor words in other languages) and creating synonym groups.
* **Reverse Dictionaries:** A universal `Translation` model enables the creation of multi-directional dictionaries (e.g., Anik'e-English and English-Anik'e).

### Content Core (Encyclopedia)

* **Unified Content Model (`ContentEntry`):** All public encyclopedic content (articles, historical events, characters, locations, etc.) is based on a single base model using **Single Table Inheritance (STI)**. This provides a unified interface for searching, managing, and versioning.
* **Private Notes:** The `Note` model exists separately from public content and is intended for authors' private work notes.

### Cross-Cutting Systems

* **Soft Deletion:** All key entities use the **`discard`** gem for safe archiving instead of permanent deletion. The uniqueness of slugs is guaranteed at the database level using **partial unique indexes**.
* **Versioning:** The use of the **`PaperTrail`** gem is planned to track the complete history of changes for all content, turning the project into a "living chronicle".
* **Authorization:** A flexible permission system based on the **Pundit** gem is planned for future implementation.

## Tech Stack

* **Ruby:** 3.3.3
* **Rails:** 7.2.2.2
* **Database:** PostgreSQL
* **Frontend:** Hotwire (Turbo + Stimulus)
* **Assets:** Propshaft, esbuild, Tailwind CSS

## Setup & Launch

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/anixd/anive_world.git
    cd AniveWorld
    ```

2.  **Install dependencies:**
    ```bash
    bundle install
    yarn install
    ```

3.  **Configure the database:**
  * Ensure PostgreSQL is running.
  * Copy `config/database.yml.example` to `config/database.yml` and adjust connection details if necessary.
  * Run the setup command to create, migrate, and seed the database:
    ```bash
    rails db:setup
    ```

4.  **Start the development server:**
    Use `bin/dev` to run the Rails server, JS bundler, and CSS watcher concurrently (pre-edit the `Procfile.dev` file to suit your needs.)
    ```bash
    bin/dev
    ```
    The application will be available at `http://localhost:3000`.

---
