import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["select", "textField", "richTextField", "imageField"]

    connect() {
        this.toggle()
    }

    toggle() {
        const postType = this.selectTarget.value
    
        // Hide all fields initially
        this.textFieldTarget.style.display = 'none';
        this.richTextFieldTarget.style.display = 'none';
        this.imageFieldTarget.style.display = 'none';

        // Show the relevant field
        switch(postType) {
            case 'plain_text':
                this.textFieldTarget.style.display = 'block';
                break;
            case 'rich_text':
                this.richTextFieldTarget.style.display = 'block';
                break;
            case 'image_only':
                this.imageFieldTarget.style.display = 'block';
                break;
        }
    }    
}