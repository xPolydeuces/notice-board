import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["select", "textField", "richTextField", "imageField", "pdfField"]

    connect() {
        this.toggle()
    }

    toggle() {
        const postType = this.selectTarget.value

        // Hide all fields initially using Tailwind's hidden class
        this.textFieldTarget.classList.add('hidden');
        this.richTextFieldTarget.classList.add('hidden');
        this.imageFieldTarget.classList.add('hidden');
        this.pdfFieldTarget.classList.add('hidden');

        // Show the relevant field by removing the hidden class
        switch(postType) {
            case 'plain_text':
                this.textFieldTarget.classList.remove('hidden');
                break;
            case 'rich_text':
                this.richTextFieldTarget.classList.remove('hidden');
                break;
            case 'image_only':
                this.imageFieldTarget.classList.remove('hidden');
                break;
            case 'pdf_only':
                this.pdfFieldTarget.classList.remove('hidden');
                break;
        }
    }
}