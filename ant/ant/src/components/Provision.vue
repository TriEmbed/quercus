<template>
  <v-card>
    <v-card-text>
      <v-data-table :headers="headers" :items="ssid">
    </v-card-text>
  </v-card>
</template>

<script>

export default {
  data() {
    return {
      headers: [{ text: 'ssid', value: 'SSID' },
        { text: 'RSSI', value: 'RSSI' },
        { text: 'Channel', value: 'Channel' },
        { text: 'Authmode', value: 'Authmode' },
        { text: 'Pairwise Cipher', value: 'Pairwise Cipher' },
        { text: 'Group_Cipher', value: 'Group_Cipher' }],
      ssid: [],
    };
  },
  mounted() {
    this.getStatus();
  },
  methods: {
    getStatus() {
      const xhr = new XMLHttpRequest();
      const requestURL = '/wifi';
      xhr.open('GET', requestURL, false);
      xhr.send('wifi');
      if (xhr.readyState === 4 && xhr.status === 200) {
        const response = JSON.parse(xhr.responseText);
        console.log(response);
        this.ssid = response;
        // document.getElementById('latest_firmware').innerHTML = 'Latest Firmware:  ' + response.compile_date + ' - ' + response.compile_time
        //
        // // If flashing was complete it will return a 1, else -1
        // // A return of 0 is just for information on the Latest Firmware request
        // if (response.status === 1) {
        //   // Init the countdown timer time
        //   this.seconds = 10
        //   // Start the countdown timer
        //   this.startMyTimer()
        // } else if (response.status === -1) {
        //   document.getElementById('status').innerHTML = '!!! Upload Error !!!'
        // }
      }
    },
    myFunction() {
      const x = document.getElementById('selectedFile');
      const file = x.files[0];
      console.log(' myFunction: function ');
      document.getElementById('file_info').innerHTML = `<h4>File: ${file.name}<br>` + `Size: ${file.size} bytes</h>`;
    },
    getstatus() {
      const xhr = new XMLHttpRequest();
      const requestURL = '/status';
      xhr.open('POST', requestURL, false);
      xhr.send('status');
      if (xhr.readyState === 4 && xhr.status === 200) {
        const response = JSON.parse(xhr.responseText);

        document.getElementById('latest_firmware').innerHTML = `Latest Firmware:  ${response.compile_date} - ${response.compile_time}`;

        // If flashing was complete it will return a 1, else -1
        // A return of 0 is just for information on the Latest Firmware request
        if (response.status === 1) {
          // Init the countdown timer time
          this.seconds = 10;
          // Start the countdown timer
          this.startMyTimer();
        } else if (response.status === -1) {
          document.getElementById('status').innerHTML = '!!! Upload Error !!!';
        }
      }
    },
    // progress on transfers from the server to the client (downloads)
    updateProgress(oEvent) {
      if (oEvent.lengthComputable) {
        this.getstatus();
      } else {
        window.alert('total size is unknown');
      }
    },
    updateFirmware() {
      const formData = new FormData();

      const fileSelect = document.getElementById('selectedFile');

      if (fileSelect.files && fileSelect.files.length === 1) {
        const file = fileSelect.files[0];
        formData.set('file', file, file.name);
        document.getElementById('status').innerHTML = `Uploading ${file.name} , Please Wait...`;

        // Http Request
        const request = new XMLHttpRequest();

        request.upload.addEventListener('progress', this.updateProgress);

        request.open('POST', '/update');
        request.responseType = 'blob';
        request.send(formData);
      } else {
        window.alert('Select A File First');
      }
    },
    startMyTimer() {
      document.getElementById('status').innerHTML = `Flashing Complete, Reboot in: ${this.seconds}`;

      if (--this.seconds === 0) {
        clearTimeout(this.mytimerVar);
        window.location.reload();
      } else {
        this.mytimerVar = setTimeout(this.startMyTimer, 1000);
      }
    },
  },
};
</script>
